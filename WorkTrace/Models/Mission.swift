import Foundation

struct Mission: Identifiable, Codable, Equatable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let sessions: [Session]

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var dominantApp: String {
        var durationByApp: [String: TimeInterval] = [:]

        for session in sessions {
            durationByApp[session.dominantApp, default: 0] += session.duration
        }

        return durationByApp.max { left, right in
            if left.value == right.value {
                return left.key.localizedCaseInsensitiveCompare(right.key) == .orderedDescending
            }

            return left.value < right.value
        }?.key ?? "Unknown App"
    }

    var appCount: Int {
        Set(sessions.flatMap { session in
            session.activityBlocks.map(\.bundleIdentifier)
        }).count
    }

    var sessionCount: Int {
        sessions.count
    }

    var confidence: Double {
        guard !sessions.isEmpty else {
            return 0
        }

        let totalConfidence = sessions.reduce(0) { $0 + $1.confidence }
        return min(max(totalConfidence / Double(sessions.count), 0), 1)
    }

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        sessions: [Session]
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.sessions = sessions
    }
}
