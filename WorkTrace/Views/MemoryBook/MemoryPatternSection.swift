import SwiftUI

struct MemoryPatternSection: View {
    let patterns: [Pattern]

    var body: some View {
        MemoryBookSection(title: "Patterns") {
            if patterns.isEmpty {
                Text("Repeated work structures will appear after similar Missions occur.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(patterns.prefix(3))) { pattern in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pattern.sequence.joined(separator: " -> "))
                                .font(.callout)
                                .fontWeight(.medium)
                                .lineLimit(2)

                            Text("\(pattern.frequency)x, average \(DashboardFormatters.duration(pattern.averageDuration, hasActivity: pattern.averageDuration > 0))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
