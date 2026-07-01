import SwiftUI

struct PatternSummaryView: View {
    let patterns: [Pattern]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pattern Summary")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                PatternMetric(title: "Patterns Found", value: "\(patterns.count)")
                PatternMetric(title: "Top Frequency", value: "\(topFrequency)")
                PatternMetric(title: "Last Updated", value: lastUpdatedText)
            }

            if patterns.isEmpty {
                Text("Repeated structures will appear after similar Missions occur.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 110), spacing: 10, alignment: .top)
        ]
    }

    private var topFrequency: Int {
        patterns.map(\.frequency).max() ?? 0
    }

    private var lastUpdatedText: String {
        guard let lastSeen = patterns.map(\.lastSeen).max() else {
            return "—"
        }

        return lastSeen.formatted(date: .omitted, time: .shortened)
    }
}

private struct PatternMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
