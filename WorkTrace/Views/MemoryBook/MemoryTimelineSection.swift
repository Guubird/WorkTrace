import SwiftUI

struct MemoryTimelineSection: View {
    let timeline: Timeline
    let missions: [Mission]

    var body: some View {
        MemoryBookSection(title: "Today") {
            if timeline.items.isEmpty {
                Text(missions.isEmpty ? "No Missions have been compressed into today's Timeline yet." : "Timeline entries will appear after today's Missions are ordered.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(timeline.items.prefix(8))) { item in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(item.startTime.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                                .frame(width: 54, alignment: .leading)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.dominantApp)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .lineLimit(1)

                                Text(DashboardFormatters.duration(item.duration, hasActivity: true))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .layoutPriority(1)

                            Spacer()
                        }
                    }

                    if timeline.items.count > 8 {
                        Text("\(timeline.items.count - 8) more Timeline entries remain in today's compressed history.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct MemoryBookSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
