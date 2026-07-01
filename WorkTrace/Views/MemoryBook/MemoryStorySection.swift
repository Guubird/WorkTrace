import SwiftUI

struct MemoryStorySection: View {
    let story: Story?
    let showsSummary: Bool

    var body: some View {
        MemoryBookSection(title: "Daily Story") {
            if let story {
                VStack(alignment: .leading, spacing: 8) {
                    if showsSummary {
                        Text(story.generatedSummary)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    if story.highlights.isEmpty {
                        Text("Highlights will appear after Missions are detected.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(story.highlights.prefix(4)), id: \.self) { highlight in
                            Text(highlight)
                                .font(.callout)
                                .lineLimit(2)
                        }
                    }
                }
            } else {
                Text("No work activity recorded yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
