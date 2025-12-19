import Foundation

/// Status of a pomodoro session
enum SessionStatus: String, Codable {
    case completed   // User completed the exercise break
    case cancelled   // User cancelled/quit before completing
    case inProgress  // Session is currently running
}

/// Represents a pomodoro work session
struct PomodoroSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startTime: Date
    var endTime: Date
    let exerciseType: String
    var journalEntry: String?
    var photoSessionPath: String?  // Path to photos folder for this session
    var status: SessionStatus

    init(
        id: UUID = UUID(),
        startTime: Date,
        endTime: Date = Date(),
        exerciseType: String,
        journalEntry: String? = nil,
        photoSessionPath: String? = nil,
        status: SessionStatus = .completed
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.exerciseType = exerciseType
        self.journalEntry = journalEntry
        self.photoSessionPath = photoSessionPath
        self.status = status
    }

    /// Duration of the work session in minutes
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }

    /// Formatted time string (e.g., "9:30 AM")
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    /// Formatted date string (e.g., "Dec 19")
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: startTime)
    }

    /// Hour of the day (0-23) for schedule positioning
    var hourOfDay: Int {
        Calendar.current.component(.hour, from: startTime)
    }
}

/// Manages persistence and retrieval of pomodoro sessions
class SessionStore: ObservableObject {
    @Published var sessions: [PomodoroSession] = []

    private let sessionsFileURL: URL

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appFolder = documentsPath.appendingPathComponent("XtremePomodoro", isDirectory: true)
        sessionsFileURL = appFolder.appendingPathComponent("sessions.json")

        // Ensure directory exists
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        loadSessions()
    }

    // MARK: - CRUD Operations

    func addSession(_ session: PomodoroSession) {
        sessions.append(session)
        saveSessions()
    }

    func updateJournal(for sessionId: UUID, entry: String?) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index].journalEntry = entry
            saveSessions()
        }
    }

    func updateStatus(for sessionId: UUID, status: SessionStatus, endTime: Date = Date()) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index].status = status
            sessions[index].endTime = endTime
            saveSessions()
        }
    }

    func deleteSession(_ session: PomodoroSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }

    // MARK: - Query Methods

    /// Get sessions for a specific date
    func sessions(for date: Date) -> [PomodoroSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
            .sorted { $0.startTime < $1.startTime }
    }

    /// Get sessions for a specific week
    func sessionsForWeek(containing date: Date) -> [Date: [PomodoroSession]] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return [:]
        }

        var result: [Date: [PomodoroSession]] = [:]
        for dayOffset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let dayStart = calendar.startOfDay(for: day)
                result[dayStart] = sessions(for: day)
            }
        }
        return result
    }

    /// Get the start date of the week containing a given date
    func weekStart(for date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }

    /// Get all dates in the week containing a given date
    func weekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let start = weekStart(for: date)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    // MARK: - Persistence

    private func loadSessions() {
        guard FileManager.default.fileExists(atPath: sessionsFileURL.path) else {
            sessions = []
            return
        }

        do {
            let data = try Data(contentsOf: sessionsFileURL)
            sessions = try JSONDecoder().decode([PomodoroSession].self, from: data)
        } catch {
            print("Error loading sessions: \(error)")
            sessions = []
        }
    }

    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: sessionsFileURL, options: .atomic)
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
}
