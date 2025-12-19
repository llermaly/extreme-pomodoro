import SwiftUI
import Combine

/// Manages the Pomodoro timer countdown
class PomodoroTimer: ObservableObject {
    // MARK: - Published State
    @Published var timeRemaining: Int = 0  // seconds
    @Published var timerState: TimerState = .idle
    @Published var sessionType: SessionType = .work

    enum TimerState {
        case idle
        case running
        case paused
    }

    enum SessionType {
        case work
        case breakTime

        var label: String {
            switch self {
            case .work: return "Work"
            case .breakTime: return "Break"
            }
        }
    }

    // MARK: - Configuration
    var workDurationMinutes: Int = 25
    var breakDurationMinutes: Int = 5

    // MARK: - Callbacks
    var onWorkSessionStart: (() -> Void)?
    var onWorkSessionComplete: (() -> Void)?
    var onBreakSessionComplete: (() -> Void)?

    // MARK: - Private
    private var timer: AnyCancellable?

    // MARK: - Computed
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        let totalSeconds: Double
        switch sessionType {
        case .work:
            totalSeconds = Double(workDurationMinutes * 60)
        case .breakTime:
            totalSeconds = Double(breakDurationMinutes * 60)
        }
        guard totalSeconds > 0 else { return 0 }
        return Double(timeRemaining) / totalSeconds
    }

    // MARK: - Actions
    func startWorkSession() {
        sessionType = .work
        timeRemaining = workDurationMinutes * 60
        timerState = .running
        onWorkSessionStart?()
        startTimer()
    }

    func startBreakSession() {
        sessionType = .breakTime
        timeRemaining = breakDurationMinutes * 60
        timerState = .running
        startTimer()
    }

    func pause() {
        timerState = .paused
        timer?.cancel()
    }

    func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        startTimer()
    }

    func reset() {
        timer?.cancel()
        timerState = .idle
        sessionType = .work
        timeRemaining = workDurationMinutes * 60
    }

    func togglePause() {
        if timerState == .running {
            pause()
        } else if timerState == .paused {
            resume()
        }
    }

    /// Debug: Skip to end of current session
    func skipToEnd() {
        timer?.cancel()
        timeRemaining = 0
        handleTimerComplete()
    }

    // MARK: - Private Methods
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard timerState == .running else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            handleTimerComplete()
        }
    }

    private func handleTimerComplete() {
        timer?.cancel()
        timerState = .idle

        switch sessionType {
        case .work:
            onWorkSessionComplete?()
        case .breakTime:
            onBreakSessionComplete?()
        }
    }
}
