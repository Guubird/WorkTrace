import SwiftUI

struct TopAppsView: View {
    let summaries: [AppUsageSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Apps")
                .font(.headline)
                .fontWeight(.semibold)

            if summaries.isEmpty {
                Text("No samples yet today.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(summaries.prefix(5))) { summary in
                        HStack(alignment: .firstTextBaseline) {
                            Text(summary.appName)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .layoutPriority(1)
                            Spacer()
                            Text("\(summary.sampleCount) samples")
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .font(.caption)
                            Text(summary.totalMinutes.formatted(.number.precision(.fractionLength(1))) + " min")
                                .monospacedDigit()
                                .frame(width: 70, alignment: .trailing)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)

                        if summary.id != summaries.prefix(5).last?.id {
                            Divider()
                        }
                    }

                    if summaries.count > 5 {
                        Text("\(summaries.count - 5) more apps available later.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
