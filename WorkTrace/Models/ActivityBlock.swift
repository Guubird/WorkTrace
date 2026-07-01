import Foundation

struct ActivityBlock: Identifiable, Codable, Equatable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let primaryApp: String
    let bundleIdentifier: String
    let windowTitle: String?
    let sampleCount: Int

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date,
        primaryApp: String,
        bundleIdentifier: String,
        windowTitle: String? = nil,
        sampleCount: Int
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.primaryApp = primaryApp
        self.bundleIdentifier = bundleIdentifier
        self.windowTitle = windowTitle
        self.sampleCount = sampleCount
    }
}
