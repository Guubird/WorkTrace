import SwiftUI

struct SectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct StatusPill: View {
    let isRunning: Bool

    var body: some View {
        Label(isRunning ? "Running" : "Paused", systemImage: isRunning ? "record.circle.fill" : "pause.circle")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(isRunning ? .green : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(Capsule())
    }
}

struct ToolbarIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))
                .frame(width: 26, height: 24)
        }
        .buttonStyle(.borderless)
        .disabled(isDisabled)
        .help(accessibilityLabel)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct CompactDisclosureSection<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content
    @State private var isExpanded: Bool

    init(
        title: String,
        subtitle: String? = nil,
        isExpanded: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        _isExpanded = State(initialValue: isExpanded)
    }

    var body: some View {
        SectionCard {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding(.top, 12)
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.headline)

                    Spacer()

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
