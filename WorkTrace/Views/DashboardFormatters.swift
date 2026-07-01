import Foundation

enum DashboardFormatters {
    static func duration(_ duration: TimeInterval?, hasActivity: Bool = true) -> String {
        guard let duration, duration.isFinite, duration > 0 else {
            return hasActivity ? "<1m" : "0m"
        }

        let totalSeconds = Int(duration.rounded(.down))
        if totalSeconds < 60 {
            return "<1m"
        }

        let minutes = totalSeconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return remainingMinutes == 0 ? "\(hours)h" : "\(hours)h \(remainingMinutes)m"
    }

    static func confidence(_ confidence: Double?) -> String {
        guard let confidence, confidence.isFinite else {
            return "—"
        }

        let boundedConfidence = min(max(confidence, 0), 1)
        return "\(Int((boundedConfidence * 100).rounded()))%"
    }
}
