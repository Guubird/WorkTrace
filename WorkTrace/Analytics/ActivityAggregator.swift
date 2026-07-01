import Foundation

enum ActivityAggregator {
    static func todaySummaries(
        from events: [ActivityEvent],
        sampleInterval: TimeInterval,
        calendar: Calendar = .current
    ) -> [AppUsageSummary] {
        var summariesByAppName: [String: AppUsageSummary] = [:]

        for event in events where calendar.isDateInToday(event.timestamp) {
            summariesByAppName[event.appName, default: AppUsageSummary(
                appName: event.appName,
                totalMinutes: 0,
                sampleCount: 0
            )].addSample(interval: sampleInterval)
        }

        return summariesByAppName.values.sorted {
            if $0.totalMinutes == $1.totalMinutes {
                return $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending
            }

            return $0.totalMinutes > $1.totalMinutes
        }
    }
}
