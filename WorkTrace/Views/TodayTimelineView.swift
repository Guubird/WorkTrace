import SwiftUI

struct TodayTimelineView: View {
    let timeline: Timeline
    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            timelineContent
                .padding(.top, 8)
        } label: {
            HStack {
                Text("Today Timeline")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(timeline.items.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var timelineContent: some View {
        if timeline.items.isEmpty {
            Text("Today Timeline will appear after Missions are detected.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(timeline.items.prefix(5))) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(item.startTime.formatted(date: .omitted, time: .shortened))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .frame(width: 54, alignment: .leading)

                        Text(item.dominantApp)
                            .font(.callout)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.vertical, 5)
                }

                if timeline.items.count > 5 {
                    Text("\(timeline.items.count - 5) more Timeline items available later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            }
        }
    }
}
