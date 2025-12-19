import SwiftUI

/// Central app state managing navigation and settings
class AppState: ObservableObject {
    // MARK: - Navigation
    @Published var currentScreen: Screen = .pomodoro
    @Published var showExerciseOverlay: Bool = false
    @Published var showSettings: Bool = false
    @Published var showAdvancedSettings: Bool = false
    @Published var showSchedule: Bool = false
    @Published var showJournalSheet: Bool = false

    enum Screen {
        case onboarding
        case pomodoro
    }

    // MARK: - Session Tracking
    let sessionStore = SessionStore()
    var pendingSession: PomodoroSession?
    var workSessionStartTime: Date?
    var currentPhotoSessionPath: String?

    // MARK: - Onboarding
    @Published var isOnboardingComplete: Bool {
        didSet { UserDefaults.standard.set(isOnboardingComplete, forKey: Keys.isOnboardingComplete) }
    }

    // MARK: - Settings
    @Published var workDuration: Int {
        didSet { UserDefaults.standard.set(workDuration, forKey: Keys.workDuration) }
    }

    @Published var breakDuration: Int {
        didSet { UserDefaults.standard.set(breakDuration, forKey: Keys.breakDuration) }
    }

    @Published var repsRequired: Int {
        didSet { UserDefaults.standard.set(repsRequired, forKey: Keys.repsRequired) }
    }

    @Published var exerciseType: String {
        didSet { UserDefaults.standard.set(exerciseType, forKey: Keys.exerciseType) }
    }

    // MARK: - Stats
    @Published var totalSessionsCompleted: Int {
        didSet { UserDefaults.standard.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    // MARK: - Keys
    private enum Keys {
        static let isOnboardingComplete = "app.isOnboardingComplete"
        static let workDuration = "settings.workDuration"
        static let breakDuration = "settings.breakDuration"
        static let repsRequired = "settings.repsRequired"
        static let exerciseType = "settings.exerciseType"
        static let totalSessionsCompleted = "app.totalSessionsCompleted"
    }

    // MARK: - Init
    init() {
        // Load persisted values or use defaults
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: Keys.isOnboardingComplete)
        self.workDuration = UserDefaults.standard.object(forKey: Keys.workDuration) as? Int ?? 25
        self.breakDuration = UserDefaults.standard.object(forKey: Keys.breakDuration) as? Int ?? 5
        self.repsRequired = UserDefaults.standard.object(forKey: Keys.repsRequired) as? Int ?? 10
        self.exerciseType = UserDefaults.standard.string(forKey: Keys.exerciseType) ?? "sitToStand"
        self.totalSessionsCompleted = UserDefaults.standard.integer(forKey: Keys.totalSessionsCompleted)

        // Set initial screen based on onboarding status
        self.currentScreen = isOnboardingComplete ? .pomodoro : .onboarding
    }

    // MARK: - Actions
    func completeOnboarding() {
        isOnboardingComplete = true
        currentScreen = .pomodoro
    }

    func startWorkSession() {
        workSessionStartTime = Date()
    }

    func triggerExerciseBreak() {
        // Guard: Don't trigger if already showing
        guard !showExerciseOverlay else {
            print("[AppState] Exercise overlay already showing, ignoring duplicate trigger")
            return
        }
        showExerciseOverlay = true
    }

    func completeExercise() {
        print("[AppState] completeExercise() called, setting showExerciseOverlay = false")
        showExerciseOverlay = false
        totalSessionsCompleted += 1

        // Create session record for journaling later
        if let startTime = workSessionStartTime {
            let session = PomodoroSession(
                startTime: startTime,
                endTime: Date(),
                exerciseType: exerciseType,
                photoSessionPath: currentPhotoSessionPath
            )
            pendingSession = session

            // Delay showing journal sheet to allow exercise window to fully dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showJournalSheet = true
            }
        }

        workSessionStartTime = nil
        currentPhotoSessionPath = nil
    }

    func saveJournalEntry(_ entry: String?) {
        if var session = pendingSession {
            session.journalEntry = entry
            sessionStore.addSession(session)
        }
        pendingSession = nil
    }

    func resetOnboarding() {
        isOnboardingComplete = false
        currentScreen = .onboarding
    }
}
