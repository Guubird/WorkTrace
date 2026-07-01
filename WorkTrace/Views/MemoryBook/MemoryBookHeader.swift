import SwiftUI

struct MemoryBookHeader: View {
    let memoryBook: MemoryBook
    let story: Story?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today's Work Notebook")
                .font(.title2)
                .fontWeight(.semibold)

            Text(memoryBook.date.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .foregroundStyle(.secondary)

            if let story, story.totalMissionCount > 0 {
                Text("\(story.totalMissionCount) Missions captured from compressed local activity.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                Text("Compressed work history will appear here after tracking starts.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
