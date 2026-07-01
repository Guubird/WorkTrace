import SwiftUI

struct StoryView: View {
    let story: Story?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Story")
                .font(.title2)
                .fontWeight(.semibold)

            if let story {
                if story.highlights.isEmpty {
                    Text("Highlights will appear after Missions are detected.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(story.highlights.prefix(4)), id: \.self) { highlight in
                            Label(highlight, systemImage: "checkmark.circle")
                                .font(.callout)
                                .lineLimit(1)
                        }
                    }
                }
            } else {
                Text("No work activity recorded yet.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
