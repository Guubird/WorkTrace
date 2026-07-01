import Foundation

struct Timeline: Identifiable, Codable, Equatable {
    var id: Date { date }

    let date: Date
    let items: [TimelineItem]
}

struct TimelineItem: Identifiable, Codable, Equatable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let dominantApp: String
    let missionTitle: String
    let missionID: UUID

    var duration: TimeInterval {
        max(endTime.timeIntervalSince(startTime), 0)
    }

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        dominantApp: String,
        missionTitle: String,
        missionID: UUID
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = max(endTime, startTime)
        self.dominantApp = dominantApp
        self.missionTitle = missionTitle
        self.missionID = missionID
    }
}
