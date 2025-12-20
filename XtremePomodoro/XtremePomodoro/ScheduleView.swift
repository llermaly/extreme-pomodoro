import SwiftUI

/// Day progress view showing tomato blocks for each pomodoro slot
struct ScheduleView: View {
    @EnvironmentObject var appState: AppState
    @Namespace private var glassNamespace

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            // Background layer
            backgroundLayer

            VStack(spacing: 0) {
                // Header
                headerView

                // Day progress visualization
                dayProgressView

                Spacer()

                // Stats summary
                statsBar
            }
            .padding(Constants.safeAreaPadding)
        }
        .frame(minWidth: 400, minHeight: 500)
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.workAccent.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { appState.showPomodoroView() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Timer")
                }
            }
            .buttonStyle(.glass)
            .glassEffectID("backButton", in: glassNamespace)

            Spacer()

            Text("Today's Progress")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
                .glassEffectID("titleBadge", in: glassNamespace)

            Spacer()

            // Time range badge
            Text("\(formatHour(appState.workStartHour)) - \(formatHour(appState.workEndHour))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .glassEffect(.regular, in: .capsule)
                .glassEffectID("timeRange", in: glassNamespace)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Day Progress View

    private var dayProgressView: some View {
        VStack(spacing: 20) {
            // Time header showing hours
            timelineHeader

            // Tomato grid
            tomatoGrid

            // Legend
            legendView
        }
        .padding(Constants.cardPadding)
        .glassEffect(.regular, in: .rect(cornerRadius: Constants.cardCornerRadius))
        .glassEffectID("progressCard", in: glassNamespace)
    }

    private var timelineHeader: some View {
        HStack(spacing: 0) {
            ForEach(workingHours, id: \.self) { hour in
                Text(formatHourShort(hour))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var tomatoGrid: some View {
        let slots = pomodoroSlots
        let columns = min(slots.count, 8)
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: columns)

        return LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                TomatoBlock(
                    slot: slot,
                    index: index,
                    glassNamespace: glassNamespace
                )
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: 24) {
            LegendItem(color: Color.breakAccent, label: "Completed")
            LegendItem(color: .red, label: "Skipped")
            LegendItem(color: .secondary.opacity(0.3), label: "Upcoming")
            LegendItem(color: Color.workAccent, label: "In Progress")
        }
        .font(.caption)
        .padding(.top, 8)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: Constants.safeAreaPadding) {
            StatItem(value: "\(completedCount)", label: "Completed")
            StatDivider()
            StatItem(value: "\(skippedCount)", label: "Skipped")
            StatDivider()
            StatItem(value: "\(remainingCount)", label: "Remaining")
            StatDivider()
            StatItem(value: "\(totalMinutesWorked)m", label: "Focused")
        }
        .padding(Constants.statBarPadding)
        .glassEffect(.regular, in: .rect(cornerRadius: Constants.statBarCornerRadius))
        .glassEffectID("statsBar", in: glassNamespace)
    }

    // MARK: - Computed Properties

    private var workingHours: [Int] {
        Array(appState.workStartHour...appState.workEndHour)
    }

    private var pomodoroSlots: [PomodoroSlot] {
        let cycleLength = appState.workDuration + appState.breakDuration
        var slots: [PomodoroSlot] = []

        let todaySessions = appState.sessionStore.sessions(for: Date())
        let now = Date()

        var slotStartMinutes = appState.workStartHour * 60
        let endMinutes = appState.workEndHour * 60

        while slotStartMinutes + appState.workDuration <= endMinutes {
            let slotHour = slotStartMinutes / 60
            let slotMinute = slotStartMinutes % 60

            // Determine slot status
            let slotTime = calendar.date(from: DateComponents(
                year: calendar.component(.year, from: now),
                month: calendar.component(.month, from: now),
                day: calendar.component(.day, from: now),
                hour: slotHour,
                minute: slotMinute
            )) ?? now

            let slotEndTime = slotTime.addingTimeInterval(Double(appState.workDuration * 60))

            // Check if there's a session matching this slot
            let matchingSession = todaySessions.first { session in
                let sessionHour = calendar.component(.hour, from: session.startTime)
                let sessionMinute = calendar.component(.minute, from: session.startTime)
                return sessionHour == slotHour && abs(sessionMinute - slotMinute) < 10
            }

            let status: PomodoroSlot.Status
            if let session = matchingSession {
                status = session.status == .completed ? .completed : .skipped
            } else if now >= slotTime && now < slotEndTime {
                status = .inProgress
            } else if now >= slotEndTime {
                status = .skipped // Past slot with no session
            } else {
                status = .upcoming
            }

            slots.append(PomodoroSlot(
                startHour: slotHour,
                startMinute: slotMinute,
                duration: appState.workDuration,
                status: status,
                session: matchingSession
            ))

            slotStartMinutes += cycleLength
        }

        return slots
    }

    private var completedCount: Int {
        pomodoroSlots.filter { $0.status == .completed }.count
    }

    private var skippedCount: Int {
        pomodoroSlots.filter { $0.status == .skipped }.count
    }

    private var remainingCount: Int {
        pomodoroSlots.filter { $0.status == .upcoming || $0.status == .inProgress }.count
    }

    private var totalMinutesWorked: Int {
        completedCount * appState.workDuration
    }

    // MARK: - Helpers

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: 0)) ?? Date()
        return formatter.string(from: date)
    }

    private func formatHourShort(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: 0)) ?? Date()
        return formatter.string(from: date).lowercased()
    }
}

// MARK: - Data Models

struct PomodoroSlot {
    let startHour: Int
    let startMinute: Int
    let duration: Int
    let status: Status
    let session: PomodoroSession?

    enum Status {
        case upcoming
        case inProgress
        case completed
        case skipped
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        let date = Calendar.current.date(from: DateComponents(hour: startHour, minute: startMinute)) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Tomato Block View

struct TomatoBlock: View {
    let slot: PomodoroSlot
    let index: Int
    var glassNamespace: Namespace.ID

    var body: some View {
        VStack(spacing: 4) {
            // Tomato shape
            TomatoShape()
                .fill(tomatoColor)
                .frame(width: 50, height: 50)
                .overlay(
                    TomatoShape()
                        .stroke(tomatoColor.opacity(0.8), lineWidth: 2)
                )
                .shadow(color: tomatoColor.opacity(0.3), radius: 4, x: 0, y: 2)
                .overlay(
                    // Status icon
                    statusIcon
                )

            // Time label
            Text(slot.timeString)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .glassEffectID("tomato-\(index)", in: glassNamespace)
    }

    private var tomatoColor: Color {
        switch slot.status {
        case .completed:
            return Color.breakAccent
        case .skipped:
            return .red
        case .inProgress:
            return Color.workAccent
        case .upcoming:
            return .secondary.opacity(0.3)
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch slot.status {
        case .completed:
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        case .skipped:
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        case .inProgress:
            Image(systemName: "play.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white)
        case .upcoming:
            EmptyView()
        }
    }
}

// MARK: - Tomato Shape

struct TomatoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY

        // Main tomato body (slightly squashed circle)
        let bodyWidth = width * 0.9
        let bodyHeight = height * 0.85
        let bodyY = centerY + height * 0.05

        path.addEllipse(in: CGRect(
            x: centerX - bodyWidth / 2,
            y: bodyY - bodyHeight / 2,
            width: bodyWidth,
            height: bodyHeight
        ))

        // Stem/leaf at top
        let stemWidth = width * 0.25
        let stemHeight = height * 0.15
        let stemY = bodyY - bodyHeight / 2 - stemHeight * 0.3

        path.addEllipse(in: CGRect(
            x: centerX - stemWidth / 2,
            y: stemY,
            width: stemWidth,
            height: stemHeight
        ))

        return path
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Stat Components (shared with PomodoroView)

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatDivider: View {
    var body: some View {
        Divider()
            .frame(height: 40)
    }
}

#Preview {
    ScheduleView()
        .environmentObject(AppState())
        .frame(width: 500, height: 600)
}
