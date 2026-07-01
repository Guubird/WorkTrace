import SwiftUI

struct TimelineView: View {
    let events: [ActivityEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Timeline")
                .font(.headline)
                .fontWeight(.semibold)

            if events.isEmpty {
                Text("Recent activity samples will appear here.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(events.prefix(5))) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(event.timestamp.formatted(date: .omitted, time: .standard))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 78, alignment: .leading)

                                Text(event.appName)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .layoutPriority(1)

                                Spacer()
                            }

                            if let windowTitle = event.windowTitle {
                                Text(windowTitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .padding(.leading, 78)
                            }
                        }
                        .padding(.vertical, 8)

                        if event.id != events.prefix(5).last?.id {
                            Divider()
                        }
                    }

                    if events.count > 5 {
                        Text("\(events.count - 5) more recent Samples available later.")
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
