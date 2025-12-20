import AppKit
import SwiftUI
import Combine

/// Manages the menu bar status item for the pomodoro timer
class MenuBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()
    private weak var pomodoroTimer: PomodoroTimer?
    private weak var appState: AppState?

    static let shared = MenuBarController()

    private override init() {
        super.init()
    }

    /// Setup the menu bar item with timer subscription
    func setup(timer: PomodoroTimer, appState: AppState) {
        self.pomodoroTimer = timer
        self.appState = appState

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Configure button
        if statusItem?.button != nil {
            updateButton(timeRemaining: timer.timeRemaining, state: timer.timerState, sessionType: timer.sessionType)
        }

        // Create and attach the menu
        statusItem?.menu = createMenu()

        // Subscribe to timer updates
        timer.$timeRemaining
            .combineLatest(timer.$timerState, timer.$sessionType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRemaining, state, sessionType in
                self?.updateButton(timeRemaining: timeRemaining, state: state, sessionType: sessionType)
            }
            .store(in: &cancellables)
    }

    /// Create the dropdown menu
    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Timer status (non-clickable header)
        let statusItem = NSMenuItem(title: "XtremePomodoro", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)

        menu.addItem(NSMenuItem.separator())

        // Show Timer
        let showItem = NSMenuItem(title: "Show Timer", action: #selector(showTimerWindow), keyEquivalent: "t")
        showItem.target = self
        menu.addItem(showItem)

        // Start/Pause Timer
        let timerControlItem = NSMenuItem(title: "Start Timer", action: #selector(toggleTimer), keyEquivalent: "s")
        timerControlItem.target = self
        menu.addItem(timerControlItem)

        // Reset Timer
        let resetItem = NSMenuItem(title: "Reset Timer", action: #selector(resetTimer), keyEquivalent: "r")
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(NSMenuItem.separator())

        // Session History
        let historyItem = NSMenuItem(title: "Session History", action: #selector(showHistory), keyEquivalent: "h")
        historyItem.target = self
        menu.addItem(historyItem)

        // Settings
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit XtremePomodoro", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Set delegate to update menu items dynamically
        menu.delegate = self

        return menu
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

    // MARK: - Menu Actions

    @objc private func showTimerWindow() {
        NSApp.activate(ignoringOtherApps: true)

        for window in NSApp.windows {
            if window.isVisible && !window.title.contains("Exercise") {
                window.makeKeyAndOrderFront(nil)
                break
            }
        }
    }

    @objc private func toggleTimer() {
        guard let timer = pomodoroTimer else { return }

        if timer.timerState == .idle {
            timer.startWorkSession()
        } else {
            timer.togglePause()
        }
    }

    @objc private func resetTimer() {
        pomodoroTimer?.reset()
    }

    @objc private func showHistory() {
        NSApp.activate(ignoringOtherApps: true)
        appState?.showScheduleView()
        showTimerWindow()
    }

    @objc private func showSettings() {
        NSApp.activate(ignoringOtherApps: true)
        appState?.showSettings = true
        showTimerWindow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
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

// MARK: - NSMenuDelegate

extension MenuBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Update menu items based on current timer state
        guard let timer = pomodoroTimer else { return }

        // Find and update the timer control item
        for item in menu.items {
            if item.action == #selector(toggleTimer) {
                switch timer.timerState {
                case .idle:
                    item.title = "Start Timer"
                case .running:
                    item.title = "Pause Timer"
                case .paused:
                    item.title = "Resume Timer"
                }
            }

            // Update the header with current status
            if item.action == nil && item.title != "" && !item.isSeparatorItem {
                if timer.timerState == .idle {
                    item.title = "XtremePomodoro"
                } else {
                    let sessionLabel = timer.sessionType == .work ? "Working" : "Break"
                    let stateLabel = timer.timerState == .paused ? " (Paused)" : ""
                    item.title = "\(sessionLabel)\(stateLabel)"
                }
            }
        }
    }
}
