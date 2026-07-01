import Foundation

struct Story: Identifiable, Codable, Equatable {
    var id: Date { date }

    let date: Date
    let missions: [Mission]
    let totalMissionCount: Int
    let totalSessionCount: Int
    let totalDuration: TimeInterval
    let dominantApp: String
    let generatedSummary: String
    let highlights: [String]

    var sessions: [Session] {
        missions.flatMap(\.sessions)
    }

    var totalFocusTime: TimeInterval {
        totalDuration
    }

    var title: String {
        "Daily Work Story"
    }

    init(
        date: Date,
        missions: [Mission],
        generatedSummary: String = "No work activity recorded yet.",
        highlights: [String] = []
    ) {
        let sessions = missions.flatMap(\.sessions)

        self.date = date
        self.missions = missions
        self.totalMissionCount = missions.count
        self.totalSessionCount = sessions.count
        self.totalDuration = missions.reduce(0) { $0 + max($1.duration, 0) }
        self.dominantApp = Self.calculateDominantApp(from: missions)
        self.generatedSummary = generatedSummary
        self.highlights = highlights
    }

    init(
        date: Date,
        sessions: [Session],
        generatedSummary: String = "No work activity recorded yet.",
        highlights: [String] = []
    ) {
        self.init(
            date: date,
            missions: MissionDetector.detectMissions(from: sessions),
            generatedSummary: generatedSummary,
            highlights: highlights
        )
    }

    private static func calculateDominantApp(from missions: [Mission]) -> String {
        var durationByApp: [String: TimeInterval] = [:]

        for mission in missions {
            durationByApp[mission.dominantApp, default: 0] += max(mission.duration, 0)
        }

        return durationByApp.max { left, right in
            if left.value == right.value {
                return left.key.localizedCaseInsensitiveCompare(right.key) == .orderedDescending
            }

            return left.value < right.value
        }?.key ?? "—"
    }
}
