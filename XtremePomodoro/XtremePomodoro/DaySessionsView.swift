import SwiftUI

/// View showing all sessions for a specific day with Liquid Glass styled blocks
struct DaySessionsView: View {
    let date: Date
    @ObservedObject var sessionStore: SessionStore
    @Binding var navigationPath: NavigationPath
    @Namespace private var glassNamespace

    private let calendar = Calendar.current

    var sessions: [PomodoroSession] {
        sessionStore.sessions(for: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with glass navigation
            headerView

            Divider()

            if sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    // Grid of session blocks with glass effects
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Constants.sessionGridSpacing) {
                        ForEach(sessions) { session in
                            SessionSquare(session: session, glassNamespace: glassNamespace) {
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

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { navigationPath.removeLast() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            .buttonStyle(.glass)
            .glassEffectID("backButton", in: glassNamespace)

            Spacer()

            Text(dateTitle)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
                .glassEffectID("dateTitle", in: glassNamespace)

            Spacer()

            // Placeholder for symmetry
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .opacity(0)
        }
        .padding()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No sessions this day")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Complete pomodoro sessions to see them here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

/// A square block representing a single session with Liquid Glass styling
struct SessionSquare: View {
    let session: PomodoroSession
    var glassNamespace: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Time range
                Text(timeRange)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary.opacity(0.9))

                // Duration - primary focus
                Text("\(session.durationMinutes)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                // Exercise icon
                Image(systemName: exerciseIcon)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
            .frame(width: Constants.sessionItemSize, height: Constants.sessionItemSize)
        }
        .buttonStyle(.glass)
        .glassEffect(.regular, in: .rect(cornerRadius: Constants.sessionItemCornerRadius))
        .glassEffectID("session-\(session.id)", in: glassNamespace)
        .overlay(
            // Subtle status indicator at corner
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .padding(8),
            alignment: .topTrailing
        )
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }

    private var statusColor: Color {
        switch session.status {
        case .completed:
            return Color.breakAccent
        case .cancelled:
            return .red
        case .inProgress:
            return .secondary
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
