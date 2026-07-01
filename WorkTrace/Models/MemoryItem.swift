import Foundation

enum MemoryItemType: String, Codable, Equatable {
    case dailySummary
    case dominantApp
    case longMission
    case repeatedPattern
    case timelineShape
}

struct MemoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let type: MemoryItemType
    let title: String
    let detail: String
    let confidence: Double
    let sourceCount: Int
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        type: MemoryItemType,
        title: String,
        detail: String,
        confidence: Double,
        sourceCount: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.title = title
        self.detail = detail
        self.confidence = min(max(confidence, 0), 1)
        self.sourceCount = max(sourceCount, 0)
        self.createdAt = createdAt
    }
}
