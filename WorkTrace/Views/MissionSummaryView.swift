import SwiftUI

struct MissionSummaryView: View {
    let missions: [Mission]

    private var todayMissions: [Mission] {
        missions.filter { Calendar.current.isDateInToday($0.startTime) }
    }

    private var latestMission: Mission? {
        todayMissions.last
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mission Summary")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                MissionMetric(title: "Today", value: "\(todayMissions.count)")
                MissionMetric(title: "Duration", value: DashboardFormatters.duration(latestMission?.duration, hasActivity: latestMission != nil))
                MissionMetric(title: "Dominant App", value: latestMission?.dominantApp ?? "—")
                MissionMetric(title: "Sessions", value: latestMission.map { "\($0.sessionCount)" } ?? "0")
            }

            if let latestMission {
                Text("Latest Mission: \(latestMission.dominantApp)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                Text("Missions will appear after Sessions are detected.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 110), spacing: 10, alignment: .top)
        ]
    }
}

private struct MissionMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
