import AppKit
import SwiftUI
import Combine

/// Manages the menu bar status item for the pomodoro timer
class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private weak var pomodoroTimer: PomodoroTimer?

    static let shared = MenuBarController()

    private init() {}

    /// Setup the menu bar item with timer subscription
    func setup(timer: PomodoroTimer) {
        self.pomodoroTimer = timer

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Configure button
        if let button = statusItem?.button {
            button.action = #selector(statusItemClicked)
            button.target = self
            updateButton(timeRemaining: timer.timeRemaining, state: timer.timerState, sessionType: timer.sessionType)
        }

        // Subscribe to timer updates
        timer.$timeRemaining
            .combineLatest(timer.$timerState, timer.$sessionType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRemaining, state, sessionType in
                self?.updateButton(timeRemaining: timeRemaining, state: state, sessionType: sessionType)
            }
            .store(in: &cancellables)
    }

    /// Update the status bar button display
    private func updateButton(timeRemaining: Int, state: PomodoroTimer.TimerState, sessionType: PomodoroTimer.SessionType) {
        guard let button = statusItem?.button else { return }

        switch state {
        case .idle:
            // Show tomato icon when idle
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer")
            button.title = ""

        case .running, .paused:
            // Show time remaining
            let minutes = timeRemaining / 60
            let seconds = timeRemaining % 60
            let timeString = String(format: "%02d:%02d", minutes, seconds)

            // Set icon based on session type
            let iconName = sessionType == .work ? "circle.fill" : "leaf.fill"
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: sessionType.label)
            button.title = " \(timeString)"

            // Dim if paused
            button.alphaValue = state == .paused ? 0.6 : 1.0
        }
    }

    @objc private func statusItemClicked() {
        // Bring main window to front
        NSApp.activate(ignoringOtherApps: true)

        // Find and focus the main window
        for window in NSApp.windows {
            if window.isVisible && !window.title.contains("Exercise") {
                window.makeKeyAndOrderFront(nil)
                break
            }
        }
    }

    /// Remove the status item
    func teardown() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
        cancellables.removeAll()
    }
}
