import Foundation

struct ActivityEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let appName: String
    let bundleIdentifier: String
    let windowTitle: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        appName: String,
        bundleIdentifier: String,
        windowTitle: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.windowTitle = windowTitle
    }
}
