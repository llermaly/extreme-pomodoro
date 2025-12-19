import SwiftUI

/// Weekly schedule view showing pomodoro sessions by day
struct WeeklyScheduleView: View {
    @ObservedObject var sessionStore: SessionStore
    @State private var selectedDate: Date = Date()
    @State private var selectedSession: PomodoroSession?

    private let calendar = Calendar.current
    private let dayColors: [Color] = [
        .red.opacity(0.7),
        .orange.opacity(0.7),
        .yellow.opacity(0.7),
        .green.opacity(0.7),
        .blue.opacity(0.7),
        .indigo.opacity(0.7),
        .purple.opacity(0.7)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Week navigation header
                weekHeader

                Divider()

                // Week day cards
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                            DayCard(
                                date: date,
                                sessions: sessionStore.sessions(for: date),
                                color: dayColors[index],
                                isToday: calendar.isDateInToday(date),
                                onTap: { selectedDate = date }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Session History")
            .navigationDestination(for: Date.self) { date in
                DaySessionsView(
                    date: date,
                    sessionStore: sessionStore
                )
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session, sessionStore: sessionStore)
            }
        }
    }

    private var weekHeader: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text(weekRangeString)
                    .font(.headline)
                if isCurrentWeek {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(isCurrentWeek)
        }
        .padding()
    }

    private var weekDates: [Date] {
        sessionStore.weekDates(for: selectedDate)
    }

    private var isCurrentWeek: Bool {
        let currentWeekStart = sessionStore.weekStart(for: Date())
        let selectedWeekStart = sessionStore.weekStart(for: selectedDate)
        return calendar.isDate(currentWeekStart, inSameDayAs: selectedWeekStart)
    }

    private var weekRangeString: String {
        let dates = weekDates
        guard let first = dates.first, let last = dates.last else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startStr = formatter.string(from: first)
        let endStr = formatter.string(from: last)

        return "\(startStr) - \(endStr)"
    }

    private func previousWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextWeek() {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

/// A card representing a single day with its sessions
struct DayCard: View {
    let date: Date
    let sessions: [PomodoroSession]
    let color: Color
    let isToday: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        NavigationLink(value: date) {
            HStack(spacing: 16) {
                // Day indicator
                VStack(spacing: 4) {
                    Text(dayOfWeek)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(dayNumber)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isToday ? .white : .primary)
                }
                .frame(width: 44, height: 54)
                .background(isToday ? color : Color.clear)
                .cornerRadius(8)

                // Sessions visualization
                if sessions.isEmpty {
                    Text("No sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()

                    Spacer()
                } else {
                    // Hour blocks
                    HStack(spacing: 3) {
                        ForEach(sessions) { session in
                            SessionBlock(session: session, color: color)
                        }
                    }

                    Spacer()

                    // Session count
                    Text("\(sessions.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

/// A small block representing a single session
struct SessionBlock: View {
    let session: PomodoroSession
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(session.timeString)
                .font(.system(size: 9))
                .foregroundColor(.secondary)

            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("\(session.durationMinutes)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    WeeklyScheduleView(sessionStore: SessionStore())
        .frame(width: 500, height: 600)
}
