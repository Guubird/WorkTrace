import Foundation

enum PatternEngine {
    static func discoverPatterns(
        from stories: [Story],
        calendar: Calendar = .current
    ) -> [Pattern] {
        let missions = stories.flatMap(\.missions)
        return discoverPatterns(fromMissions: missions, calendar: calendar)
    }

    static func discoverPatterns(
        fromMissions missions: [Mission],
        calendar: Calendar = .current
    ) -> [Pattern] {
        let occurrences = missions.compactMap { occurrence(from: $0, calendar: calendar) }
        return buildPatterns(from: occurrences)
    }

    static func discoverPatterns(
        fromSessions sessions: [Session],
        calendar: Calendar = .current
    ) -> [Pattern] {
        discoverPatterns(
            fromMissions: MissionDetector.detectMissions(from: sessions),
            calendar: calendar
        )
    }

    // MARK: Repeated App Sequence

    private static func occurrence(
        from mission: Mission,
        calendar: Calendar
    ) -> PatternOccurrence? {
        let sequence = normalizedSequence(from: mission)
        guard sequence.count > 1 else {
            return nil
        }

        return PatternOccurrence(
            sequence: sequence,
            startOffset: secondsFromStartOfDay(for: mission.startTime, calendar: calendar),
            duration: max(mission.duration, 0),
            lastSeen: mission.endTime
        )
    }

    private static func normalizedSequence(from mission: Mission) -> [String] {
        var sequence: [String] = []

        for session in mission.sessions.sorted(by: { $0.startTime < $1.startTime }) {
            let app = session.dominantApp
            if sequence.last != app {
                sequence.append(app)
            }
        }

        return sequence
    }

    private static func buildPatterns(from occurrences: [PatternOccurrence]) -> [Pattern] {
        let groupedOccurrences = Dictionary(grouping: occurrences, by: \.sequence)

        return groupedOccurrences.compactMap { sequence, occurrences in
            guard occurrences.count > 1 else {
                return nil
            }

            let frequency = occurrences.count
            let averageStartTime = occurrences.reduce(0) { $0 + $1.startOffset } / Double(frequency)
            let averageDuration = occurrences.reduce(0) { $0 + $1.duration } / Double(frequency)
            let lastSeen = occurrences.map(\.lastSeen).max() ?? Date.distantPast

            return Pattern(
                sequence: sequence,
                frequency: frequency,
                averageStartTime: averageStartTime,
                averageDuration: averageDuration,
                confidence: confidence(forFrequency: frequency),
                lastSeen: lastSeen
            )
        }
        .sorted { left, right in
            if left.frequency == right.frequency {
                return left.lastSeen > right.lastSeen
            }

            return left.frequency > right.frequency
        }
    }

    private static func confidence(forFrequency frequency: Int) -> Double {
        min(max(Double(frequency) / 10, 0), 1)
    }

    private static func secondsFromStartOfDay(
        for date: Date,
        calendar: Calendar
    ) -> TimeInterval {
        date.timeIntervalSince(calendar.startOfDay(for: date))
    }

    // MARK: Future Pattern Expansion

    // Future deterministic patterns may analyze timing, Mission cadence, or Session structure.

    // MARK: Future AI Reflection

    // Future AI may consume Patterns, Stories, and Missions only, never raw Samples.
}

private struct PatternOccurrence {
    let sequence: [String]
    let startOffset: TimeInterval
    let duration: TimeInterval
    let lastSeen: Date
}
