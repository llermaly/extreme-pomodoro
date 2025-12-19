import SwiftUI

/// Main schedule view focusing on today's sessions
struct ScheduleView: View {
    @ObservedObject var sessionStore: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()

    private let calendar = Calendar.current

    var todaySessions: [PomodoroSession] {
        sessionStore.sessions(for: Date())
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)

                    Spacer()

                    Text("Today's Sessions")
                        .font(.headline)

                    Spacer()

                    // Date picker to navigate to other days
                    DatePicker("", selection: Binding(
                        get: { Date() },
                        set: { date in
                            navigationPath.append(date)
                        }
                    ), displayedComponents: .date)
                    .labelsHidden()
                    .frame(width: 30)
                }
                .padding()

                Divider()

                if todaySessions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        // Summary stats
                        summarySection

                        Divider()
                            .padding(.horizontal)

                        // Grid of session blocks
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(todaySessions) { session in
                                SessionSquare(session: session) {
                                    navigationPath.append(session)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationDestination(for: Date.self) { date in
                DaySessionsView(
                    date: date,
                    sessionStore: sessionStore,
                    navigationPath: $navigationPath
                )
            }
            .navigationDestination(for: PomodoroSession.self) { session in
                SessionDetailView(
                    session: session,
                    sessionStore: sessionStore,
                    navigationPath: $navigationPath
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "square.grid.2x2")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No sessions today")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Complete pomodoro sessions to see them here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var summarySection: some View {
        HStack(spacing: 24) {
            SummaryStat(
                value: "\(todaySessions.count)",
                label: "Sessions",
                color: .blue
            )

            SummaryStat(
                value: "\(completedCount)",
                label: "Completed",
                color: .green
            )

            SummaryStat(
                value: "\(cancelledCount)",
                label: "Cancelled",
                color: .red
            )

            SummaryStat(
                value: "\(totalMinutes)",
                label: "Minutes",
                color: .purple
            )
        }
        .padding()
    }

    private var completedCount: Int {
        todaySessions.filter { $0.status == .completed }.count
    }

    private var cancelledCount: Int {
        todaySessions.filter { $0.status == .cancelled }.count
    }

    private var totalMinutes: Int {
        todaySessions.reduce(0) { $0 + $1.durationMinutes }
    }
}

/// A summary statistic display
struct SummaryStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ScheduleView(sessionStore: SessionStore())
        .frame(width: 500, height: 600)
}
