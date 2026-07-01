//
//  WorkTraceApp.swift
//  WorkTrace
//
//  Created by 陈睿 on 2026/7/1.
//

import SwiftUI

@main
struct WorkTraceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var activityStore = ActivityStore()
    @StateObject private var activityTracker = ActivityTracker()
    @StateObject private var compressionState = CompressionState()

    var body: some Scene {
        WindowGroup("WorkTrace", id: "main") {
            DashboardView()
                .environmentObject(activityStore)
                .environmentObject(activityTracker)
                .environmentObject(compressionState)
                .onAppear {
                    activityTracker.configure(store: activityStore)
                    compressionState.configure(store: activityStore)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        MenuBarExtra("WorkTrace", systemImage: activityTracker.isTracking ? "waveform.path.ecg" : "pause.circle") {
            MenuBarControls()
                .environmentObject(activityStore)
                .environmentObject(activityTracker)
                .onAppear {
                    activityTracker.configure(store: activityStore)
                    compressionState.configure(store: activityStore)
                }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

private struct MenuBarControls: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var activityStore: ActivityStore
    @EnvironmentObject private var activityTracker: ActivityTracker

    var body: some View {
        Button("Show Dashboard") {
            NSApplication.shared.activate()
            openWindow(id: "main")
        }

        Divider()

        Button("Start Tracking") {
            activityTracker.start()
        }
        .disabled(activityTracker.isTracking)

        Button("Pause Tracking") {
            activityTracker.pause()
        }
        .disabled(!activityTracker.isTracking)

        Divider()

        Button("Clear Data") {
            activityStore.clear()
        }

        Divider()

        Button("Quit WorkTrace") {
            NSApplication.shared.terminate(nil)
        }
    }
}
