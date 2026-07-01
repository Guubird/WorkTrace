import SwiftUI

struct CompressionView: View {
    let rawSampleCount: Int
    let activityBlockCount: Int
    let sessionCount: Int
    let missionCount: Int
    let timelineItemCount: Int
    let memoryItemCount: Int
    let latestSession: Session?
    let story: Story?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Compression")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                PipelineCount(label: "Raw Samples", count: rawSampleCount)
                PipelineCount(label: "Activity Blocks", count: activityBlockCount)
                PipelineCount(label: "Sessions", count: sessionCount)
                PipelineCount(label: "Missions", count: missionCount)
                PipelineCount(label: "Timeline", count: timelineItemCount)
                PipelineCount(label: "Stories", count: story == nil ? 0 : 1)
                PipelineCount(label: "Memory", count: memoryItemCount)
            }

            Text("Pipeline: Samples, Blocks, Sessions, Missions, Timeline, Story, Patterns, Memory")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let story {
                Text("Today: \(story.title)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                Text("Today's Story will appear after Samples become Missions.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if let latestSession {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Latest Session")
                        .font(.headline)

                    HStack(spacing: 12) {
                        SessionMetric(label: "Duration", value: DashboardFormatters.duration(latestSession.duration))
                        SessionMetric(label: "Dominant App", value: latestSession.dominantApp)
                        SessionMetric(label: "Apps", value: "\(latestSession.appCount)")
                        SessionMetric(label: "Confidence", value: DashboardFormatters.confidence(latestSession.confidence))
                    }
                }
                .padding(.top, 4)
            } else {
                Text("Latest Session will appear after Activity Blocks are detected.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 96), spacing: 10, alignment: .top)
        ]
    }
}

private struct SessionMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PipelineCount: View {
    let label: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(count)")
                .font(.headline)
                .monospacedDigit()
            Text(label)
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
