import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var activityStore: ActivityStore
    @EnvironmentObject private var activityTracker: ActivityTracker
    @EnvironmentObject private var compressionState: CompressionState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                LazyVGrid(columns: primaryColumns, alignment: .leading, spacing: 16) {
                    SectionCard {
                        todaySummary
                    }
                }

                MemoryBookView(
                    memoryBook: compressionState.memoryBook,
                    story: compressionState.todayStory,
                    timeline: compressionState.todayTimeline,
                    patterns: compressionState.patterns,
                    missions: compressionState.missions
                )

                CompactDisclosureSection(title: "Diagnostics", subtitle: technicalSubtitle) {
                    LazyVGrid(columns: detailColumns, alignment: .leading, spacing: 18) {
                        CompressionView(
                            rawSampleCount: activityStore.events.count,
                            activityBlockCount: compressionState.activityBlocks.count,
                            sessionCount: compressionState.sessions.count,
                            missionCount: compressionState.missions.count,
                            timelineItemCount: compressionState.todayTimeline.items.count,
                            memoryItemCount: compressionState.memoryBook.itemCount,
                            latestSession: compressionState.sessions.last,
                            story: compressionState.todayStory
                        )
                        PatternSummaryView(patterns: compressionState.patterns)
                        MissionSummaryView(missions: compressionState.missions)
                        TopAppsView(summaries: activityStore.todaySummaries)
                        TimelineView(events: Array(activityStore.events.suffix(12).reversed()))
                    }
                }

                SectionCard {
                    DataStatusView(rawEventCount: activityStore.events.count)
                }
            }
            .frame(maxWidth: 980, alignment: .topLeading)
            .padding(20)
        }
        .frame(minWidth: 760, minHeight: 560)
    }

    private var primaryColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 330), spacing: 16, alignment: .top)
        ]
    }

    private var detailColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 300), spacing: 18, alignment: .top)
        ]
    }

    private var technicalSubtitle: String {
        "\(activityStore.events.count) Samples"
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WorkTrace")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Local work memory. Private, quiet, and on this Mac.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                StatusPill(isRunning: activityTracker.isTracking)

                ToolbarIconButton(
                    systemImage: activityTracker.isTracking ? "pause.fill" : "play.fill",
                    accessibilityLabel: activityTracker.isTracking ? "Pause Tracking" : "Start Tracking"
                ) {
                    if activityTracker.isTracking {
                        activityTracker.pause()
                    } else {
                        activityTracker.start()
                    }
                }

                ToolbarIconButton(systemImage: "trash", accessibilityLabel: "Clear Data") {
                    activityStore.clear()
                }

                ToolbarIconButton(
                    systemImage: "gearshape",
                    accessibilityLabel: "Settings Placeholder",
                    isDisabled: true
                ) { }
            }
        }
    }

    private var todaySummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Today Summary")
                    .font(.headline)

                Spacer()

                Text("\(Int(ActivityTracker.sampleInterval))s interval")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                SummaryMetric(title: "Apps", value: "\(activityStore.todaySummaries.count)")
                SummaryMetric(title: "Samples", value: "\(todaySampleCount)")
                SummaryMetric(title: "Memory", value: "\(compressionState.memoryBook.itemCount)")
            }

            if let lastSampledAt = activityTracker.lastSampledAt, let lastSampledAppName = activityTracker.lastSampledAppName {
                Text("Last sample: \(lastSampledAppName), \(lastSampledAt.formatted(date: .omitted, time: .shortened))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("Start tracking to record the frontmost app locally.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var todaySampleCount: Int {
        activityStore.events.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    }
}

private struct SummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ActivityStore())
            .environmentObject(ActivityTracker())
            .environmentObject(CompressionState())
    }
}
