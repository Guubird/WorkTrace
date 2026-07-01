import Foundation
import Testing
@testable import WorkTrace

struct WorkTraceTests {
    @Test func aggregatorBuildsTodaySummaries() {
        let now = Date()
        let events = [
            ActivityEvent(timestamp: now, appName: "Xcode", bundleIdentifier: "com.apple.dt.Xcode"),
            ActivityEvent(timestamp: now, appName: "Xcode", bundleIdentifier: "com.apple.dt.Xcode"),
            ActivityEvent(timestamp: now, appName: "Safari", bundleIdentifier: "com.apple.Safari")
        ]

        let summaries = ActivityAggregator.todaySummaries(from: events, sampleInterval: 10)

        #expect(summaries.count == 2)
        #expect(summaries.first?.appName == "Xcode")
        #expect(summaries.first?.sampleCount == 2)
        #expect(summaries.first?.totalMinutes == 20.0 / 60.0)
    }

    @MainActor
    @Test func storeDropsExpiredEventsAndCanClearData() throws {
        let storageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("WorkTraceTests-\(UUID().uuidString)")
            .appendingPathComponent("activity-events.json")

        let expiredDate = Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date()
        let currentEvent = ActivityEvent(appName: "Xcode", bundleIdentifier: "com.apple.dt.Xcode")
        let expiredEvent = ActivityEvent(timestamp: expiredDate, appName: "Old App", bundleIdentifier: "old.app")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try FileManager.default.createDirectory(at: storageURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encoder.encode([expiredEvent, currentEvent]).write(to: storageURL)

        let store = ActivityStore(storageURL: storageURL)

        #expect(store.events.count == 1)
        #expect(store.events.first?.id == currentEvent.id)
        #expect(store.events.first?.appName == currentEvent.appName)
        #expect(store.events.first?.bundleIdentifier == currentEvent.bundleIdentifier)
        #expect(store.todaySummaries.count == 1)

        store.clear()

        #expect(store.events.isEmpty)
        #expect(store.todaySummaries.isEmpty)
    }

    @Test func compressionEngineBuildsPermanentPipeline() {
        let now = Date()
        let samples = [
            ActivityEvent(timestamp: now, appName: "Xcode", bundleIdentifier: "com.apple.dt.Xcode"),
            ActivityEvent(timestamp: now.addingTimeInterval(10), appName: "Xcode", bundleIdentifier: "com.apple.dt.Xcode"),
            ActivityEvent(timestamp: now.addingTimeInterval(20), appName: "Safari", bundleIdentifier: "com.apple.Safari")
        ]

        let blocks = CompressionEngine.compressSamplesIntoBlocks(samples, sampleInterval: 10)
        let sessions = CompressionEngine.compressBlocksIntoSessions(blocks)
        let missions = CompressionEngine.compressSessionsIntoMissions(sessions)
        let story = CompressionEngine.buildDailyStory(for: now, missions: missions)

        #expect(blocks.count == 2)
        #expect(blocks.first?.primaryApp == "Xcode")
        #expect(blocks.first?.sampleCount == 2)
        #expect(sessions.count == 1)
        #expect(missions.count == 1)
        #expect(sessions.allSatisfy { $0.title == "General Work Session" })
        #expect(story.sessions.count == 1)
        #expect(story.missions.count == 1)
        #expect(story.generatedSummary.contains("Today includes"))
        #expect(story.highlights.count == 4)
    }

    @Test func storyGeneratorBuildsSafeEmptyStory() {
        let story = StoryGenerator.buildDailyStory(missions: [])

        #expect(story.missions.isEmpty)
        #expect(story.totalMissionCount == 0)
        #expect(story.totalSessionCount == 0)
        #expect(story.totalDuration == 0)
        #expect(story.dominantApp == "—")
        #expect(story.generatedSummary == "No work activity recorded yet.")
        #expect(story.highlights.isEmpty)
    }

    @Test func storyGeneratorBuildsGeneratedSummaryFromMissions() {
        let now = Date()
        let missions = [
            Mission(
                startTime: now,
                endTime: now.addingTimeInterval(1_200),
                sessions: [
                    makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 1_200)
                ]
            )
        ]

        let story = StoryGenerator.buildDailyStory(for: now, missions: missions)

        #expect(story.generatedSummary == "Today includes 1 Mission, 1 Session, mainly focused around Xcode.")
    }

    @Test func storyGeneratorCalculatesMissionAndSessionCounts() {
        let now = Date()
        let missionOneSessions = [
            makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 600),
            makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(900), duration: 300)
        ]
        let missionTwoSessions = [
            makeSession(app: "Notes", bundleIdentifier: "com.apple.Notes", startTime: now.addingTimeInterval(3_600), duration: 300)
        ]
        let missions = [
            Mission(startTime: now, endTime: now.addingTimeInterval(1_200), sessions: missionOneSessions),
            Mission(startTime: now.addingTimeInterval(3_600), endTime: now.addingTimeInterval(3_900), sessions: missionTwoSessions)
        ]

        let story = StoryGenerator.buildDailyStory(for: now, missions: missions)

        #expect(story.totalMissionCount == 2)
        #expect(story.totalSessionCount == 3)
    }

    @Test func storyGeneratorCalculatesDominantApp() {
        let now = Date()
        let missions = [
            Mission(
                startTime: now,
                endTime: now.addingTimeInterval(1_500),
                sessions: [
                    makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 1_500)
                ]
            ),
            Mission(
                startTime: now.addingTimeInterval(3_600),
                endTime: now.addingTimeInterval(3_900),
                sessions: [
                    makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(3_600), duration: 300)
                ]
            )
        ]

        let story = StoryGenerator.buildDailyStory(for: now, missions: missions)

        #expect(story.dominantApp == "Xcode")
    }

    @Test func storyGeneratorBuildsHighlights() {
        let now = Date()
        let missions = [
            Mission(
                startTime: now,
                endTime: now.addingTimeInterval(1_200),
                sessions: [
                    makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 1_200)
                ]
            )
        ]

        let story = StoryGenerator.buildDailyStory(for: now, missions: missions)

        #expect(story.highlights.count == 4)
        #expect(story.highlights.contains("Longest Mission: 20m"))
        #expect(story.highlights.contains("Dominant App: Xcode"))
        #expect(story.highlights.contains("Total Sessions: 1"))
        #expect(story.highlights.contains("Total Missions: 1"))
    }

    @Test func patternEngineHandlesEmptyStories() {
        let patterns = PatternEngine.discoverPatterns(from: [])

        #expect(patterns.isEmpty)
    }

    @Test func patternEngineDetectsRepeatedAppSequences() {
        let now = Date()
        let missions = [
            makeMission(apps: ["Slack", "Chrome", "Xcode"], startTime: now, duration: 900),
            makeMission(apps: ["Mail", "Notes"], startTime: now.addingTimeInterval(3_600), duration: 600),
            makeMission(apps: ["Slack", "Chrome", "Xcode"], startTime: now.addingTimeInterval(86_400), duration: 1_200)
        ]

        let patterns = PatternEngine.discoverPatterns(fromMissions: missions)

        #expect(patterns.count == 1)
        #expect(patterns.first?.sequence == ["Slack", "Chrome", "Xcode"])
    }

    @Test func patternEngineCalculatesFrequency() {
        let now = Date()
        let missions = [
            makeMission(apps: ["Slack", "Chrome", "Xcode"], startTime: now, duration: 900),
            makeMission(apps: ["Slack", "Chrome", "Xcode"], startTime: now.addingTimeInterval(86_400), duration: 900),
            makeMission(apps: ["Slack", "Chrome", "Xcode"], startTime: now.addingTimeInterval(172_800), duration: 900)
        ]

        let pattern = PatternEngine.discoverPatterns(fromMissions: missions)[0]

        #expect(pattern.frequency == 3)
    }

    @Test func patternEngineCalculatesAverageStartTime() {
        let calendar = Calendar(identifier: .gregorian)
        let day = calendar.startOfDay(for: Date())
        let missions = [
            makeMission(apps: ["Slack", "Chrome"], startTime: day.addingTimeInterval(9 * 3_600), duration: 600),
            makeMission(apps: ["Slack", "Chrome"], startTime: day.addingTimeInterval(10 * 3_600), duration: 600)
        ]

        let pattern = PatternEngine.discoverPatterns(fromMissions: missions, calendar: calendar)[0]

        #expect(pattern.averageStartTime == 34_200)
    }

    @Test func patternEngineConfidenceIsBounded() {
        let now = Date()
        let missions = (0..<12).map { index in
            makeMission(
                apps: ["Slack", "Chrome"],
                startTime: now.addingTimeInterval(Double(index) * 86_400),
                duration: 600
            )
        }

        let pattern = PatternEngine.discoverPatterns(fromMissions: missions)[0]

        #expect((0.0...1.0).contains(pattern.confidence))
        #expect(pattern.confidence == 1.0)
    }

    @Test func timelineBuilderSortsChronologically() {
        let day = Calendar.current.startOfDay(for: Date())
        let missions = [
            makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(10 * 3_600), duration: 600),
            makeMission(apps: ["Chrome"], startTime: day.addingTimeInterval(9 * 3_600), duration: 600)
        ]

        let timeline = TimelineBuilder.buildTodayTimeline(from: missions, for: day)

        #expect(timeline.items.map(\.dominantApp) == ["Chrome", "Xcode"])
    }

    @Test func timelineBuilderHandlesEmptyDay() {
        let day = Calendar.current.startOfDay(for: Date())

        let timeline = TimelineBuilder.buildTodayTimeline(from: [], for: day)

        #expect(timeline.items.isEmpty)
        #expect(timeline.date == day)
    }

    @Test func timelineBuilderCreatesSingleMissionItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_200)

        let timeline = TimelineBuilder.buildTodayTimeline(from: [mission], for: day)

        #expect(timeline.items.count == 1)
        #expect(timeline.items.first?.missionID == mission.id)
        #expect(timeline.items.first?.dominantApp == "Xcode")
    }

    @Test func timelineBuilderCreatesMultipleMissionItems() {
        let day = Calendar.current.startOfDay(for: Date())
        let missions = [
            makeMission(apps: ["Chrome"], startTime: day.addingTimeInterval(9 * 3_600), duration: 600),
            makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(10 * 3_600), duration: 600),
            makeMission(apps: ["ChatGPT"], startTime: day.addingTimeInterval(11 * 3_600), duration: 600)
        ]

        let timeline = TimelineBuilder.buildTodayTimeline(from: missions, for: day)

        #expect(timeline.items.count == 3)
        #expect(timeline.items.map(\.dominantApp) == ["Chrome", "Xcode", "ChatGPT"])
    }

    @Test func timelineBuilderProtectsAgainstOverlaps() {
        let day = Calendar.current.startOfDay(for: Date())
        let missions = [
            makeMission(apps: ["Chrome"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_800),
            makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600 + 900), duration: 1_800)
        ]

        let timeline = TimelineBuilder.buildTodayTimeline(from: missions, for: day)

        #expect(timeline.items.count == 2)
        #expect(timeline.items[1].startTime >= timeline.items[0].endTime)
    }

    @Test func timelineBuilderCalculatesDurationCorrectly() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_500)

        let timeline = TimelineBuilder.buildTodayTimeline(from: [mission], for: day)

        #expect(timeline.items.first?.duration == 1_500)
    }

    @Test func memoryBuilderHandlesEmptyInput() {
        let day = Calendar.current.startOfDay(for: Date())
        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: nil,
            timeline: Timeline(date: day, items: []),
            patterns: [],
            missions: []
        )

        #expect(memoryBook.items.isEmpty)
        #expect(memoryBook.itemCount == 0)
        #expect(memoryBook.date == day)
    }

    @Test func memoryBuilderCreatesDailySummaryItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_200)
        let story = Story(
            date: day,
            missions: [mission],
            generatedSummary: "Today includes 1 Mission."
        )

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: story,
            timeline: Timeline(date: day, items: []),
            patterns: [],
            missions: [mission]
        )

        #expect(memoryBook.items.contains { $0.type == .dailySummary && $0.detail == "Today includes 1 Mission." })
    }

    @Test func memoryBuilderCreatesDominantAppItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_200)
        let story = Story(date: day, missions: [mission], generatedSummary: "Summary")

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: story,
            timeline: Timeline(date: day, items: []),
            patterns: [],
            missions: [mission]
        )

        #expect(memoryBook.items.contains { $0.type == .dominantApp && $0.detail == "Xcode" })
    }

    @Test func memoryBuilderCreatesLongMissionItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 2_400)

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: nil,
            timeline: Timeline(date: day, items: []),
            patterns: [],
            missions: [mission]
        )

        #expect(memoryBook.items.contains { $0.type == .longMission && $0.detail.contains("40m") })
    }

    @Test func memoryBuilderCreatesRepeatedPatternItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let pattern = Pattern(
            sequence: ["Slack", "Chrome", "Xcode"],
            frequency: 3,
            averageStartTime: 9 * 3_600,
            averageDuration: 900,
            confidence: 0.3,
            lastSeen: day.addingTimeInterval(10 * 3_600)
        )

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: nil,
            timeline: Timeline(date: day, items: []),
            patterns: [pattern],
            missions: []
        )

        #expect(memoryBook.items.contains { $0.type == .repeatedPattern && $0.detail.contains("3x") })
    }

    @Test func memoryBuilderCreatesTimelineShapeItem() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_200)
        let timeline = TimelineBuilder.buildTodayTimeline(from: [mission], for: day)

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: nil,
            timeline: timeline,
            patterns: [],
            missions: []
        )

        #expect(memoryBook.items.contains { $0.type == .timelineShape && $0.detail == "1 items, 20m" })
    }

    @Test func memoryBuilderDoesNotRequireRawSamples() {
        let day = Calendar.current.startOfDay(for: Date())
        let mission = makeMission(apps: ["Xcode"], startTime: day.addingTimeInterval(9 * 3_600), duration: 1_200)
        let story = Story(date: day, missions: [mission], generatedSummary: "Summary")
        let timeline = TimelineBuilder.buildTodayTimeline(from: [mission], for: day)

        let memoryBook = MemoryBuilder.buildTodayMemoryBook(
            for: day,
            story: story,
            timeline: timeline,
            patterns: [],
            missions: [mission]
        )

        #expect(!memoryBook.items.isEmpty)
    }

    @Test func sessionDetectorMergesActivityBlocksWithShortGaps() {
        let now = Date()
        let blocks = [
            makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 300),
            makeBlock(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(360), duration: 300)
        ]

        let sessions = SessionDetector.detectSessions(from: blocks, idleThreshold: 600)

        #expect(sessions.count == 1)
        #expect(sessions.first?.activityBlocks.count == 2)
    }

    @Test func sessionDetectorSplitsActivityBlocksWithLongGaps() {
        let now = Date()
        let blocks = [
            makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 300),
            makeBlock(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(1_200), duration: 300)
        ]

        let sessions = SessionDetector.detectSessions(from: blocks, idleThreshold: 600)

        #expect(sessions.count == 2)
    }

    @Test func sessionMetadataCalculatesDominantAppAppCountAndSwitchCount() {
        let now = Date()
        let blocks = [
            makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 600),
            makeBlock(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(660), duration: 120),
            makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now.addingTimeInterval(840), duration: 300)
        ]

        let session = SessionDetector.detectSessions(from: blocks, idleThreshold: 600)[0]

        #expect(session.dominantApp == "Xcode")
        #expect(session.appCount == 2)
        #expect(session.switchCount == 2)
    }

    @Test func sessionConfidenceIsDeterministicAndBounded() {
        let now = Date()
        let singleAppSession = SessionDetector.detectSessions(
            from: [
                makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 300)
            ],
            idleThreshold: 600
        )[0]

        let mixedSession = SessionDetector.detectSessions(
            from: [
                makeBlock(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 120),
                makeBlock(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(180), duration: 120),
                makeBlock(app: "Notes", bundleIdentifier: "com.apple.Notes", startTime: now.addingTimeInterval(360), duration: 120),
                makeBlock(app: "Mail", bundleIdentifier: "com.apple.mail", startTime: now.addingTimeInterval(540), duration: 120)
            ],
            idleThreshold: 600
        )[0]

        #expect(singleAppSession.confidence == 0.95)
        #expect(mixedSession.confidence == 0.55)
        #expect((0.0...1.0).contains(singleAppSession.confidence))
        #expect((0.0...1.0).contains(mixedSession.confidence))
    }

    @Test func missionDetectorMergesSessionsWithShortGaps() {
        let now = Date()
        let sessions = [
            makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 600),
            makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(1_200), duration: 600)
        ]

        let missions = MissionDetector.detectMissions(from: sessions, idleThreshold: 900)

        #expect(missions.count == 1)
        #expect(missions.first?.sessionCount == 2)
    }

    @Test func missionDetectorSplitsSessionsWithLongGaps() {
        let now = Date()
        let sessions = [
            makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 600),
            makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(1_501), duration: 600)
        ]

        let missions = MissionDetector.detectMissions(from: sessions, idleThreshold: 900)

        #expect(missions.count == 2)
    }

    @Test func missionDetectorUsesIdleGapThresholdStrictly() {
        let now = Date()
        let sessions = [
            makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 600),
            makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(1_500), duration: 600)
        ]

        let missions = MissionDetector.detectMissions(from: sessions, idleThreshold: 900)

        #expect(missions.count == 2)
    }

    @Test func missionStatisticsAggregateSessions() {
        let now = Date()
        let sessions = [
            makeSession(app: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", startTime: now, duration: 1_200),
            makeSession(app: "Safari", bundleIdentifier: "com.apple.Safari", startTime: now.addingTimeInterval(1_500), duration: 300)
        ]

        let mission = MissionDetector.detectMissions(from: sessions, idleThreshold: 900)[0]

        #expect(mission.sessionCount == 2)
        #expect(mission.dominantApp == "Xcode")
        #expect(mission.appCount == 2)
        #expect(mission.duration == 1_800)
        #expect((0.0...1.0).contains(mission.confidence))
    }

    @Test func dashboardFormattersDisplaySafeDurations() {
        #expect(DashboardFormatters.duration(nil, hasActivity: false) == "0m")
        #expect(DashboardFormatters.duration(nil, hasActivity: true) == "<1m")
        #expect(DashboardFormatters.duration(-30, hasActivity: true) == "<1m")
        #expect(DashboardFormatters.duration(30, hasActivity: true) == "<1m")
        #expect(DashboardFormatters.duration(120, hasActivity: true) == "2m")
        #expect(DashboardFormatters.duration(3_600, hasActivity: true) == "1h")
        #expect(DashboardFormatters.duration(3_900, hasActivity: true) == "1h 5m")
    }

    @Test func dashboardFormattersDisplaySafeConfidence() {
        #expect(DashboardFormatters.confidence(nil) == "—")
        #expect(DashboardFormatters.confidence(.nan) == "—")
        #expect(DashboardFormatters.confidence(-0.5) == "0%")
        #expect(DashboardFormatters.confidence(0.75) == "75%")
        #expect(DashboardFormatters.confidence(1.5) == "100%")
    }

    private func makeBlock(
        app: String,
        bundleIdentifier: String,
        startTime: Date,
        duration: TimeInterval
    ) -> ActivityBlock {
        ActivityBlock(
            startTime: startTime,
            endTime: startTime.addingTimeInterval(duration),
            primaryApp: app,
            bundleIdentifier: bundleIdentifier,
            sampleCount: 1
        )
    }

    private func makeSession(
        app: String,
        bundleIdentifier: String,
        startTime: Date,
        duration: TimeInterval
    ) -> Session {
        let block = makeBlock(
            app: app,
            bundleIdentifier: bundleIdentifier,
            startTime: startTime,
            duration: duration
        )

        return Session(
            startTime: startTime,
            endTime: startTime.addingTimeInterval(duration),
            activityBlocks: [block]
        )
    }

    private func makeMission(
        apps: [String],
        startTime: Date,
        duration: TimeInterval
    ) -> Mission {
        let sessionDuration = duration / Double(apps.count)
        let sessions = apps.enumerated().map { index, app in
            makeSession(
                app: app,
                bundleIdentifier: "com.worktrace.\(app.lowercased())",
                startTime: startTime.addingTimeInterval(Double(index) * sessionDuration),
                duration: sessionDuration
            )
        }

        return Mission(
            startTime: startTime,
            endTime: startTime.addingTimeInterval(duration),
            sessions: sessions
        )
    }
}
