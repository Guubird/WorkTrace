import Combine
import Foundation

@MainActor
final class CompressionState: ObservableObject {
    @Published private(set) var activityBlocks: [ActivityBlock] = []
    @Published private(set) var sessions: [Session] = []
    @Published private(set) var missions: [Mission] = []
    @Published private(set) var todayTimeline = Timeline(date: Calendar.current.startOfDay(for: Date()), items: [])
    @Published private(set) var todayStory: Story?
    @Published private(set) var patterns: [Pattern] = []
    @Published private(set) var memoryBook = MemoryBook(date: Calendar.current.startOfDay(for: Date()), items: [])

    private var cancellable: AnyCancellable?

    func configure(store: ActivityStore) {
        guard cancellable == nil else {
            return
        }

        rebuild(from: store.events)
        cancellable = store.$events
            .sink { [weak self] events in
                self?.rebuild(from: events)
            }
    }

    private func rebuild(from samples: [ActivityEvent]) {
        let blocks = CompressionEngine.compressSamplesIntoBlocks(
            samples,
            sampleInterval: ActivityTracker.sampleInterval
        )
        let compressedSessions = CompressionEngine.compressBlocksIntoSessions(blocks)
        let compressedMissions = CompressionEngine.compressSessionsIntoMissions(compressedSessions)

        let timeline = CompressionEngine.buildTodayTimeline(missions: compressedMissions)
        let story = CompressionEngine.buildDailyStory(missions: compressedMissions)
        let discoveredPatterns = PatternEngine.discoverPatterns(fromMissions: compressedMissions)

        activityBlocks = blocks
        sessions = compressedSessions
        missions = compressedMissions
        todayTimeline = timeline
        todayStory = story
        patterns = discoveredPatterns
        memoryBook = MemoryBuilder.buildTodayMemoryBook(
            story: story,
            timeline: timeline,
            patterns: discoveredPatterns,
            missions: compressedMissions
        )
    }
}
