import Combine
import Foundation

@MainActor
final class ActivityStore: ObservableObject {
    static let retentionDays = 3

    @Published private(set) var events: [ActivityEvent] = []
    @Published private(set) var todaySummaries: [AppUsageSummary] = []

    private let storageURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(storageURL: URL? = nil) {
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let defaultDirectory = applicationSupport?.appendingPathComponent("WorkTrace", isDirectory: true)
        let defaultURL = defaultDirectory?.appendingPathComponent("activity-events.json")

        self.storageURL = storageURL ?? defaultURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("worktrace-activity-events.json")

        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601

        load()
        cleanupExpiredEvents()
        refreshTodaySummaries()
    }

    func record(_ event: ActivityEvent, sampleInterval: TimeInterval) {
        events.append(event)
        cleanupExpiredEvents(saveAfterCleanup: false)
        updateTodaySummary(with: event, sampleInterval: sampleInterval)
        save()
    }

    func clear() {
        events.removeAll()
        todaySummaries.removeAll()
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            events = []
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            events = try decoder.decode([ActivityEvent].self, from: data)
        } catch {
            events = []
        }
    }

    private func save() {
        do {
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(events)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            // v0.1 deliberately keeps storage failure non-fatal.
        }
    }

    private func cleanupExpiredEvents(saveAfterCleanup: Bool = true) {
        let cutoff = Calendar.current.date(byAdding: .day, value: -Self.retentionDays, to: Date()) ?? Date()
        let originalCount = events.count
        events.removeAll { $0.timestamp < cutoff }

        if saveAfterCleanup, events.count != originalCount {
            save()
        }
    }

    private func refreshTodaySummaries() {
        todaySummaries = ActivityAggregator.todaySummaries(
            from: events,
            sampleInterval: ActivityTracker.sampleInterval
        )
    }

    private func updateTodaySummary(with event: ActivityEvent, sampleInterval: TimeInterval) {
        guard Calendar.current.isDateInToday(event.timestamp) else {
            return
        }

        if let index = todaySummaries.firstIndex(where: { $0.appName == event.appName }) {
            todaySummaries[index].addSample(interval: sampleInterval)
        } else {
            todaySummaries.append(AppUsageSummary(
                appName: event.appName,
                totalMinutes: sampleInterval / 60,
                sampleCount: 1
            ))
        }

        todaySummaries.sort {
            if $0.totalMinutes == $1.totalMinutes {
                return $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending
            }

            return $0.totalMinutes > $1.totalMinutes
        }
    }
}
