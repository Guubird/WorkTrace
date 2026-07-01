import Foundation

struct AppUsageSummary: Identifiable, Codable, Equatable {
    var id: String { appName }

    let appName: String
    var totalMinutes: Double
    var sampleCount: Int

    mutating func addSample(interval: TimeInterval) {
        sampleCount += 1
        totalMinutes += interval / 60
    }
}
