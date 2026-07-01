import Foundation

struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let startTime: Date
    let endTime: Date
    let activityBlocks: [ActivityBlock]
    let dominantApp: String
    let appCount: Int
    let switchCount: Int
    let confidence: Double

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    init(
        id: UUID = UUID(),
        title: String = "General Work Session",
        startTime: Date,
        endTime: Date,
        activityBlocks: [ActivityBlock],
        dominantApp: String? = nil,
        appCount: Int? = nil,
        switchCount: Int? = nil,
        confidence: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.activityBlocks = activityBlocks
        self.dominantApp = dominantApp ?? Self.calculateDominantApp(from: activityBlocks)
        self.appCount = appCount ?? Self.calculateAppCount(from: activityBlocks)
        self.switchCount = switchCount ?? Self.calculateSwitchCount(from: activityBlocks)
        self.confidence = min(max(confidence ?? Self.calculateConfidence(from: activityBlocks), 0), 1)
    }

    private static func calculateDominantApp(from activityBlocks: [ActivityBlock]) -> String {
        var durationByApp: [String: TimeInterval] = [:]

        for block in activityBlocks {
            durationByApp[block.primaryApp, default: 0] += block.duration
        }

        return durationByApp.max { left, right in
            if left.value == right.value {
                return left.key.localizedCaseInsensitiveCompare(right.key) == .orderedDescending
            }

            return left.value < right.value
        }?.key ?? "Unknown App"
    }

    private static func calculateAppCount(from activityBlocks: [ActivityBlock]) -> Int {
        Set(activityBlocks.map(\.bundleIdentifier)).count
    }

    private static func calculateSwitchCount(from activityBlocks: [ActivityBlock]) -> Int {
        max(activityBlocks.count - 1, 0)
    }

    private static func calculateConfidence(from activityBlocks: [ActivityBlock]) -> Double {
        let appCount = calculateAppCount(from: activityBlocks)
        let switchCount = calculateSwitchCount(from: activityBlocks)

        if appCount <= 1 {
            return 0.95
        }

        if appCount <= 3, switchCount <= 5 {
            return 0.75
        }

        return 0.55
    }
}
