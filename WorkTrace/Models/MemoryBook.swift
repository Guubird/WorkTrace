import Foundation

struct MemoryBook: Identifiable, Codable, Equatable {
    var id: Date { date }

    let date: Date
    let items: [MemoryItem]
    let generatedAt: Date

    var itemCount: Int {
        items.count
    }

    init(
        date: Date,
        items: [MemoryItem],
        generatedAt: Date = Date()
    ) {
        self.date = date
        self.items = items
        self.generatedAt = generatedAt
    }
}
