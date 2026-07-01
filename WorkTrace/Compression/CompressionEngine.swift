import Foundation

enum CompressionEngine {
    static func compressSamplesIntoBlocks(
        _ samples: [ActivityEvent],
        sampleInterval: TimeInterval
    ) -> [ActivityBlock] {
        let sortedSamples = samples.sorted { $0.timestamp < $1.timestamp }
        guard let firstSample = sortedSamples.first else {
            return []
        }

        var blocks: [ActivityBlock] = []
        var currentSamples: [ActivityEvent] = [firstSample]

        for sample in sortedSamples.dropFirst() {
            if belongsInCurrentActivityBlock(sample, currentSamples: currentSamples) {
                currentSamples.append(sample)
            } else {
                blocks.append(makeActivityBlock(from: currentSamples, sampleInterval: sampleInterval))
                currentSamples = [sample]
            }
        }

        blocks.append(makeActivityBlock(from: currentSamples, sampleInterval: sampleInterval))
        return blocks
    }

    // MARK: Session Detection

    static func compressBlocksIntoSessions(_ blocks: [ActivityBlock]) -> [Session] {
        SessionDetector.detectSessions(from: blocks)
    }

    // MARK: Mission Detection

    static func compressSessionsIntoMissions(_ sessions: [Session]) -> [Mission] {
        MissionDetector.detectMissions(from: sessions)
    }

    // MARK: Timeline Generation

    static func buildTodayTimeline(
        for date: Date = Date(),
        missions: [Mission],
        calendar: Calendar = .current
    ) -> Timeline {
        TimelineBuilder.buildTodayTimeline(
            from: missions,
            for: date,
            calendar: calendar
        )
    }

    // MARK: Story Generation

    static func buildDailyStory(
        for date: Date = Date(),
        missions: [Mission],
        calendar: Calendar = .current
    ) -> Story {
        StoryGenerator.buildDailyStory(
            for: date,
            missions: missions,
            calendar: calendar
        )
    }

    static func buildDailyStory(
        for date: Date = Date(),
        sessions: [Session],
        calendar: Calendar = .current
    ) -> Story {
        buildDailyStory(
            for: date,
            missions: compressSessionsIntoMissions(sessions),
            calendar: calendar
        )
    }

    // MARK: AI Reflection

    // Future AI reflection must only operate on Timeline, Story, Pattern, Mission, and Session, never raw Samples.

    // MARK: Reminder Engine

    // Reminders are intentionally not implemented in Phase 3.

    private static func belongsInCurrentActivityBlock(
        _ sample: ActivityEvent,
        currentSamples: [ActivityEvent]
    ) -> Bool {
        guard let previousSample = currentSamples.last else {
            return true
        }

        return previousSample.bundleIdentifier == sample.bundleIdentifier
    }

    private static func makeActivityBlock(
        from samples: [ActivityEvent],
        sampleInterval: TimeInterval
    ) -> ActivityBlock {
        let firstSample = samples[0]
        let lastSample = samples[samples.count - 1]
        let endTime = lastSample.timestamp.addingTimeInterval(sampleInterval)

        return ActivityBlock(
            startTime: firstSample.timestamp,
            endTime: endTime,
            primaryApp: firstSample.appName,
            bundleIdentifier: firstSample.bundleIdentifier,
            windowTitle: firstSample.windowTitle,
            sampleCount: samples.count
        )
    }
}
