import Foundation

struct Pattern: Identifiable, Codable, Equatable {
    let id: UUID
    let sequence: [String]
    let frequency: Int
    let averageStartTime: TimeInterval
    let averageDuration: TimeInterval
    let confidence: Double
    let lastSeen: Date

    init(
        id: UUID = UUID(),
        sequence: [String],
        frequency: Int,
        averageStartTime: TimeInterval,
        averageDuration: TimeInterval,
        confidence: Double,
        lastSeen: Date
    ) {
        self.id = id
        self.sequence = sequence
        self.frequency = max(frequency, 0)
        self.averageStartTime = max(averageStartTime, 0)
        self.averageDuration = max(averageDuration, 0)
        self.confidence = min(max(confidence, 0), 1)
        self.lastSeen = lastSeen
    }
}
