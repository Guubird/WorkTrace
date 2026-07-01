import Foundation

enum StoryGenerator {
    static func buildDailyStory(
        for date: Date = Date(),
        missions: [Mission],
        calendar: Calendar = .current
    ) -> Story {
        let dayStart = calendar.startOfDay(for: date)
        let todayMissions = missions
            .filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            .sorted { $0.startTime < $1.startTime }

        guard !todayMissions.isEmpty else {
            return Story(
                date: dayStart,
                missions: [],
                generatedSummary: "No work activity recorded yet.",
                highlights: []
            )
        }

        let draftStory = Story(date: dayStart, missions: todayMissions)

        return Story(
            date: dayStart,
            missions: todayMissions,
            generatedSummary: summary(for: draftStory),
            highlights: highlights(for: draftStory, missions: todayMissions)
        )
    }

    // MARK: Local Story Generation

    private static func summary(for story: Story) -> String {
        "Today includes \(story.totalMissionCount) \(plural("Mission", count: story.totalMissionCount)), \(story.totalSessionCount) \(plural("Session", count: story.totalSessionCount)), mainly focused around \(story.dominantApp)."
    }

    private static func highlights(for story: Story, missions: [Mission]) -> [String] {
        let longestMissionDuration = missions
            .map { max($0.duration, 0) }
            .max() ?? 0

        return [
            "Longest Mission: \(formatDuration(longestMissionDuration))",
            "Dominant App: \(story.dominantApp)",
            "Total Sessions: \(story.totalSessionCount)",
            "Total Missions: \(story.totalMissionCount)"
        ]
    }

    private static func plural(_ word: String, count: Int) -> String {
        count == 1 ? word : "\(word)s"
    }

    private static func formatDuration(_ duration: TimeInterval) -> String {
        guard duration.isFinite, duration > 0 else {
            return "0m"
        }

        let totalSeconds = Int(duration.rounded(.down))
        if totalSeconds < 60 {
            return "<1m"
        }

        let minutes = totalSeconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return remainingMinutes == 0 ? "\(hours)h" : "\(hours)h \(remainingMinutes)m"
    }

    // MARK: Future AI-Assisted Story Reflection

    // Future AI may consume Stories and Missions only, never raw Samples.
}
