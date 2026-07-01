import SwiftUI

struct MemoryFactsSection: View {
    let memoryBook: MemoryBook

    var body: some View {
        MemoryBookSection(title: "Memory Facts") {
            if memoryBook.items.isEmpty {
                Text("Memory facts will appear after compressed work history exists.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(memoryBook.items.prefix(5))) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.callout)
                                .fontWeight(.medium)

                            Text(item.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}
