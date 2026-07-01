import SwiftUI

struct MemoryBookView: View {
    let memoryBook: MemoryBook
    let story: Story?
    let timeline: Timeline
    let patterns: [Pattern]
    let missions: [Mission]

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            MemoryBookHeader(memoryBook: memoryBook, story: story)

            MemoryTimelineSection(timeline: timeline, missions: missions)

            MemoryStorySection(
                story: story,
                showsSummary: !memoryBook.items.contains { $0.type == .dailySummary }
            )

            MemoryPatternSection(patterns: patterns)

            MemoryFactsSection(memoryBook: memoryBook)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}
