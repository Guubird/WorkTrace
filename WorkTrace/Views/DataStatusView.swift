import SwiftUI

struct DataStatusView: View {
    let rawEventCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data Status")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Label("\(rawEventCount) raw events stored", systemImage: "internaldrive")
                Label("Raw events retained for \(ActivityStore.retentionDays) days", systemImage: "calendar")
                Label("Local-only: no AI, no network", systemImage: "lock")
                Label("No clipboard, screenshots, content, or browser history", systemImage: "eye.slash")
                if rawEventCount == 0 {
                    Text("Start tracking to create local Samples.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
