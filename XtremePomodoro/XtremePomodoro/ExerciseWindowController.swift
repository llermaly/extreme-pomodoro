import SwiftUI
import AppKit

/// Manages a fullscreen blocking window for exercise breaks
class ExerciseWindowController: NSObject, ObservableObject {
    private var window: NSPanel?
    private var appState: AppState?

    static let shared = ExerciseWindowController()

    private override init() {
        super.init()
    }

    /// Show the fullscreen exercise overlay
    func showExerciseWindow(appState: AppState) {
        // Guard: Don't show if already showing
        guard window == nil else {
            print("[ExerciseWindow] Already showing, ignoring duplicate show request")
            return
        }

        self.appState = appState

        // Create the SwiftUI view
        let exerciseView = ExerciseOverlayView()
            .environmentObject(appState)

        // Create hosting view
        let hostingView = NSHostingView(rootView: exerciseView)

        // Get the main screen size
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame

        // Create NSPanel with specific style
        let panel = NSPanel(
            contentRect: screenFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Configure panel for fullscreen blocking
        panel.contentView = hostingView
        panel.backgroundColor = .black
        panel.isOpaque = true
        panel.hasShadow = false

        // Set to highest window level (above everything including dock and menu bar)
        panel.level = .screenSaver

        // Make it cover the entire screen including menu bar
        panel.setFrame(screenFrame, display: true)

        // Prevent it from being hidden or moved
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovable = false
        panel.isMovableByWindowBackground = false

        // Make it key and front
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()

        // Hide the cursor (optional - can be commented out if annoying)
        // NSCursor.hide()

        // Store reference
        self.window = panel

        // Set up keyboard monitoring for Cmd+Q escape
        setupKeyboardMonitor()

        // Hide dock and menu bar
        NSApp.presentationOptions = [.hideDock, .hideMenuBar, .disableProcessSwitching]
    }

    /// Dismiss the exercise window
    func dismissExerciseWindow() {
        // Guard: Don't dismiss if not showing
        guard window != nil else {
            print("[ExerciseWindow] No window to dismiss")
            return
        }

        print("[ExerciseWindow] Dismissing exercise window")

        // Restore normal presentation
        NSApp.presentationOptions = []

        // Show cursor
        NSCursor.unhide()

        // Remove keyboard monitor
        removeKeyboardMonitor()

        // Close and release window
        window?.close()
        window = nil

        // Clear references
        appState = nil
    }

    // MARK: - Keyboard Monitoring

    private var localKeyMonitor: Any?
    private var globalKeyMonitor: Any?

    private func setupKeyboardMonitor() {
        // Local monitor for when app is active
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "q" {
                self?.showQuitConfirmation()
                return nil
            }
            // Also allow Escape key as emergency exit
            if event.keyCode == 53 { // Escape key
                self?.showQuitConfirmation()
                return nil
            }
            return event
        }

        // Global monitor as backup
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "q" {
                DispatchQueue.main.async {
                    self?.showQuitConfirmation()
                }
            }
        }
    }

    private func removeKeyboardMonitor() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
    }

    private func showQuitConfirmation() {
        // Temporarily lower window level to show alert
        let previousLevel = window?.level ?? .screenSaver
        window?.level = .normal

        let alert = NSAlert()
        alert.messageText = "Quit XtremePomodoro?"
        alert.informativeText = "Are you sure you want to quit? You haven't finished your exercise yet!\n\nPress Cmd+Q again to confirm quit."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Keep Exercising")
        alert.addButton(withTitle: "Quit Anyway")

        let response = alert.runModal()

        if response == .alertSecondButtonReturn {
            // User chose to quit
            dismissExerciseWindow()
            NSApp.terminate(nil)
        } else {
            // Restore window level
            window?.level = previousLevel
            window?.makeKeyAndOrderFront(nil)
            window?.orderFrontRegardless()
        }
    }
}

/// Coordinator to bridge between SwiftUI and the window controller
class ExerciseWindowCoordinator: ObservableObject {
    @Published var isShowingExercise: Bool = false {
        didSet {
            if isShowingExercise {
                // Window will be shown by the App
            } else {
                ExerciseWindowController.shared.dismissExerciseWindow()
            }
        }
    }
}
