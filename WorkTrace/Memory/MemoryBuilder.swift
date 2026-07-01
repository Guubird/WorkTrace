import Foundation

enum MemoryBuilder {
    static func buildTodayMemoryBook(
        for date: Date = Date(),
        story: Story?,
        timeline: Timeline,
        patterns: [Pattern],
        missions: [Mission],
        calendar: Calendar = .current
    ) -> MemoryBook {
        let dayStart = calendar.startOfDay(for: date)
        let todayMissions = missions
            .filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            .sorted { $0.startTime < $1.startTime }
        let todayPatterns = patterns.sorted { left, right in
            if left.frequency == right.frequency {
                return left.lastSeen > right.lastSeen
            }

            return left.frequency > right.frequency
        }

        var items: [MemoryItem] = []

        if let story, !story.missions.isEmpty {
            items.append(dailySummaryItem(from: story, date: dayStart))

            if story.dominantApp != "—", !story.dominantApp.isEmpty {
                items.append(dominantAppItem(from: story, date: dayStart))
            }
        }

        if let longestMission = todayMissions.max(by: { $0.duration < $1.duration }),
           longestMission.duration > 30 * 60 {
            items.append(longMissionItem(from: longestMission, date: dayStart))
        }

        if let topPattern = todayPatterns.first {
            items.append(repeatedPatternItem(from: topPattern, date: dayStart))
        }

        if !timeline.items.isEmpty {
            items.append(timelineShapeItem(from: timeline, date: dayStart))
        }

        return MemoryBook(date: dayStart, items: items)
    }

    // MARK: Deterministic Memory Facts

    private static func dailySummaryItem(from story: Story, date: Date) -> MemoryItem {
        MemoryItem(
            date: date,
            type: .dailySummary,
            title: "Daily summary",
            detail: story.generatedSummary,
            confidence: 0.9,
            sourceCount: story.totalMissionCount
        )
    }

    private static func dominantAppItem(from story: Story, date: Date) -> MemoryItem {
        MemoryItem(
            date: date,
            type: .dominantApp,
            title: "Dominant app",
            detail: story.dominantApp,
            confidence: 0.85,
            sourceCount: story.totalMissionCount
        )
    }

    private static func longMissionItem(from mission: Mission, date: Date) -> MemoryItem {
        MemoryItem(
            date: date,
            type: .longMission,
            title: "Long Mission",
            detail: "\(mission.dominantApp), \(formatDuration(mission.duration))",
            confidence: 0.8,
            sourceCount: mission.sessionCount
        )
    }

    private static func repeatedPatternItem(from pattern: Pattern, date: Date) -> MemoryItem {
        MemoryItem(
            date: date,
            type: .repeatedPattern,
            title: "Repeated Pattern",
            detail: "\(pattern.sequence.joined(separator: " -> ")) (\(pattern.frequency)x)",
            confidence: pattern.confidence,
            sourceCount: pattern.frequency
        )
    }

    private static func timelineShapeItem(from timeline: Timeline, date: Date) -> MemoryItem {
        let totalDuration = timeline.items.reduce(0) { $0 + $1.duration }

        return MemoryItem(
            date: date,
            type: .timelineShape,
            title: "Timeline shape",
            detail: "\(timeline.items.count) items, \(formatDuration(totalDuration))",
            confidence: 0.8,
            sourceCount: timeline.items.count
        )
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

    // MARK: Future Reflection Context

    // Future AI may consume MemoryBook, Story, Timeline, Patterns, and Missions only.
}
