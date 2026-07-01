import AppKit
import Combine
import Foundation

@MainActor
final class ActivityTracker: ObservableObject {
    static let productionInterval: TimeInterval = 120
    static let debugInterval: TimeInterval = 10
    static let sampleInterval: TimeInterval = debugInterval

    @Published private(set) var isTracking = false
    @Published private(set) var lastSampledAt: Date?
    @Published private(set) var lastSampledAppName: String?

    private weak var store: ActivityStore?
    private var timer: Timer?

    func configure(store: ActivityStore) {
        self.store = store
    }

    func start() {
        guard !isTracking else {
            return
        }

        isTracking = true
        sampleFrontmostApplication()
        scheduleTimer()
    }

    func pause() {
        isTracking = false
        timer?.invalidate()
        timer = nil
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: Self.sampleInterval, repeats: true) { [weak self] _ in
            guard let tracker = self else {
                return
            }

            Task { @MainActor in
                tracker.sampleFrontmostApplication()
            }
        }
    }

    private func sampleFrontmostApplication() {
        guard isTracking, let runningApplication = NSWorkspace.shared.frontmostApplication else {
            return
        }

        let appName = runningApplication.localizedName ?? "Unknown App"
        let bundleIdentifier = runningApplication.bundleIdentifier ?? "unknown.bundle"
        let event = ActivityEvent(
            appName: appName,
            bundleIdentifier: bundleIdentifier,
            windowTitle: frontmostWindowTitle(for: runningApplication)
        )

        lastSampledAt = event.timestamp
        lastSampledAppName = event.appName
        store?.record(event, sampleInterval: Self.sampleInterval)
    }

    private func frontmostWindowTitle(for runningApplication: NSRunningApplication) -> String? {
        guard AXIsProcessTrusted(), runningApplication.processIdentifier > 0 else {
            return nil
        }

        let appElement = AXUIElementCreateApplication(runningApplication.processIdentifier)
        var focusedWindow: CFTypeRef?
        let windowResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedWindowAttribute as CFString,
            &focusedWindow
        )

        guard windowResult == .success, let focusedWindow else {
            return nil
        }

        var title: CFTypeRef?
        let titleResult = AXUIElementCopyAttributeValue(
            focusedWindow as! AXUIElement,
            kAXTitleAttribute as CFString,
            &title
        )

        guard titleResult == .success, let windowTitle = title as? String, !windowTitle.isEmpty else {
            return nil
        }

        return windowTitle
    }
}
