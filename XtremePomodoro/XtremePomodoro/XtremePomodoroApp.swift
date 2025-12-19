import SwiftUI
import AVFoundation

@main
struct XtremePomodoroApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var pomodoroTimer = PomodoroTimer()

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(appState)
                .environmentObject(pomodoroTimer)
                .onAppear {
                    setupTimerCallbacks()
                    MenuBarController.shared.setup(timer: pomodoroTimer)
                    requestCameraPermissionIfNeeded()
                }
                .onChange(of: appState.showExerciseOverlay) { _, showExercise in
                    if showExercise {
                        // Show aggressive fullscreen exercise window
                        ExerciseWindowController.shared.showExerciseWindow(
                            appState: appState
                        )
                    } else {
                        // Dismiss the exercise window
                        ExerciseWindowController.shared.dismissExerciseWindow()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Remove default quit command to prevent easy escape
            CommandGroup(replacing: .appTermination) {
                Button("Quit XtremePomodoro") {
                    if appState.showExerciseOverlay {
                        // During exercise, Cmd+Q is handled by the window controller
                        // This prevents the menu item from working
                    } else {
                        NSApp.terminate(nil)
                    }
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }

    private func setupTimerCallbacks() {
        // Sync timer settings with app state
        pomodoroTimer.workDurationMinutes = appState.workDuration
        pomodoroTimer.breakDurationMinutes = appState.breakDuration

        // When work session starts, record start time
        pomodoroTimer.onWorkSessionStart = { [weak appState] in
            appState?.startWorkSession()
        }

        // When work session completes, show exercise overlay
        pomodoroTimer.onWorkSessionComplete = { [weak appState] in
            appState?.triggerExerciseBreak()
        }

        // When break completes (after exercise), start next work session
        pomodoroTimer.onBreakSessionComplete = { [weak pomodoroTimer] in
            pomodoroTimer?.startWorkSession()
        }
    }

    private func requestCameraPermissionIfNeeded() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        default:
            break
        }
    }
}

/// Root view that handles navigation between app states
struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var pomodoroTimer: PomodoroTimer

    var body: some View {
        ZStack {
            // Main content based on app state
            switch appState.currentScreen {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)

            case .pomodoro:
                PomodoroView(timer: pomodoroTimer)
                    .transition(.opacity)
            }

            // Note: Exercise overlay is now shown in separate fullscreen window
            // managed by ExerciseWindowController
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
        .sheet(isPresented: $appState.showAdvancedSettings) {
            AdvancedSettingsView()
        }
        .sheet(isPresented: $appState.showSchedule) {
            ScheduleView(sessionStore: appState.sessionStore)
                .frame(minWidth: 500, minHeight: 600)
        }
        .sheet(isPresented: $appState.showJournalSheet) {
            if let session = appState.pendingSession {
                JournalEntrySheet(
                    isPresented: $appState.showJournalSheet,
                    session: session,
                    onSave: { entry in
                        appState.saveJournalEntry(entry)
                    }
                )
            }
        }
        .onChange(of: appState.workDuration) { _, newValue in
            pomodoroTimer.workDurationMinutes = newValue
        }
        .onChange(of: appState.breakDuration) { _, newValue in
            pomodoroTimer.breakDurationMinutes = newValue
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(AppState())
        .environmentObject(PomodoroTimer())
}
