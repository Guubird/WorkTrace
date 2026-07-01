import SwiftUI

struct MemoryView: View {
    let memoryBook: MemoryBook

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Memory")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(memoryBook.itemCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            if memoryBook.items.isEmpty {
                Text("Memory facts will appear after compressed work history exists.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(memoryBook.items.prefix(4)) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.callout)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            Text(item.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
