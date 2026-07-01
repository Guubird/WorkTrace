import Foundation

enum TimelineBuilder {
    static func buildTodayTimeline(
        from missions: [Mission],
        for date: Date = Date(),
        calendar: Calendar = .current
    ) -> Timeline {
        let dayStart = calendar.startOfDay(for: date)
        let todayMissions = missions
            .filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            .sorted { left, right in
                if left.startTime == right.startTime {
                    return left.endTime < right.endTime
                }

                return left.startTime < right.startTime
            }

        return Timeline(
            date: dayStart,
            items: buildItems(from: todayMissions)
        )
    }

    // MARK: Chronological Mission Timeline

    private static func buildItems(from missions: [Mission]) -> [TimelineItem] {
        var items: [TimelineItem] = []
        var previousEnd: Date?

        for mission in missions {
            let adjustedStart = max(mission.startTime, previousEnd ?? mission.startTime)
            let adjustedEnd = max(mission.endTime, adjustedStart)

            items.append(
                TimelineItem(
                    startTime: adjustedStart,
                    endTime: adjustedEnd,
                    dominantApp: mission.dominantApp,
                    missionTitle: "Mission",
                    missionID: mission.id
                )
            )

            previousEnd = adjustedEnd
        }

        return items
    }

    // MARK: Future Visual Timeline

    // Future UI may render these items as a visual time bar. TimelineBuilder remains data-only.
}
