import SwiftUI

/// View showing all sessions for a specific day with square blocks
struct DaySessionsView: View {
    let date: Date
    @ObservedObject var sessionStore: SessionStore
    @Binding var navigationPath: NavigationPath

    private let calendar = Calendar.current

    var sessions: [PomodoroSession] {
        sessionStore.sessions(for: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { navigationPath.removeLast() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)

                Spacer()

                Text(dateTitle)
                    .font(.headline)

                Spacer()

                // Placeholder for symmetry
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .opacity(0)
            }
            .padding()

            Divider()

            if sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    // Grid of session blocks
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(sessions) { session in
                            SessionSquare(session: session) {
                                navigationPath.append(session)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No sessions this day")
                .font(.headline)
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

    private var dateTitle: String {
        let formatter = DateFormatter()
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
    }
}

/// A square block representing a single session
struct SessionSquare: View {
    let session: PomodoroSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Time range
                Text(timeRange)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))

                // Duration
                Text("\(session.durationMinutes)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("min")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))

                // Exercise icon
                Image(systemName: exerciseIcon)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 100, height: 100)
            .background(statusColor)
            .cornerRadius(16)
            .shadow(color: statusColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }

    private var statusColor: Color {
        switch session.status {
        case .completed:
            return .green
        case .cancelled:
            return .red
        case .inProgress:
            return .gray
        }
    }

    private var exerciseIcon: String {
        switch session.exerciseType {
        case "sitToStand": return "figure.stand"
        case "squats": return "figure.strengthtraining.traditional"
        case "jumpingJacks": return "figure.jumprope"
        case "armRaises": return "figure.arms.open"
        default: return "figure.walk"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack(path: $path) {
                DaySessionsView(
                    date: Date(),
                    sessionStore: SessionStore(),
                    navigationPath: $path
                )
            }
            .frame(width: 500, height: 600)
        }
    }

    return PreviewWrapper()
}
