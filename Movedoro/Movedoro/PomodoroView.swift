import SwiftUI

/// Main Pomodoro timer screen
struct PomodoroView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        ZStack {
            // Content layer - the background that shines through glass
            backgroundLayer

            VStack(spacing: Constants.standardPadding) {
                // Glass toolbar floating above content
                toolbarView

                Spacer()

                // Session type indicator
                sessionTypeLabel

                // Timer display with circular progress
                timerDisplay

                // Control buttons with glass effect
                controlButtons

                // Skip Break button (only visible during break time)
                if timer.sessionType == .breakTime && timer.timerState != .idle {
                    skipBreakButton
                }

                Spacer()

                // Stats bar with glass effect
                statsBar

                // DEBUG: Skip button for testing
                #if DEBUG
                debugControls
                #endif
            }
            .padding(Constants.safeAreaPadding)
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $appState.showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            // Base background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            // Subtle gradient for depth
            RadialGradient(
                colors: [
                    timer.sessionType == .work
                        ? Color.workAccent.opacity(0.08)
                        : Color.breakAccent.opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Toolbar (Glass floating layer)

    private var toolbarView: some View {
        HStack {
            Text("Movedoro")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            // Toolbar buttons
            HStack(spacing: Constants.headerSpacing) {
                Button(action: { appState.showScheduleView() }) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
                }
                .buttonStyle(.bordered)
                .help("Today's Progress")

                Button(action: { appState.showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .frame(width: Constants.headerIconSize, height: Constants.headerIconSize)
                }
                .buttonStyle(.bordered)
                .help("Settings")
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Session Type Label

    private var sessionTypeLabel: some View {
        Text(timer.sessionType.label)
            .font(.title2)
            .fontWeight(.medium)
            // Color used here to indicate session type - key information
            .foregroundStyle(timer.sessionType == .work ? Color.workAccent : Color.breakAccent)
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.glassBackground)
                .frame(width: Constants.timerSize, height: Constants.timerSize)

            // Progress circle - color indicates session type
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    timer.sessionType == .work ? Color.workAccent : Color.breakAccent,
                    style: StrokeStyle(lineWidth: Constants.timerStrokeWidth, lineCap: .round)
                )
                .frame(width: Constants.timerSize, height: Constants.timerSize)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timer.progress)

            // Time display
            VStack(spacing: 4) {
                Text(timer.timeString)
                    .font(.system(size: Constants.timerFontSize, weight: .light, design: .rounded))
                    .monospacedDigit()

                if timer.timerState == .paused {
                    Text("PAUSED")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .fontWeight(.bold)
                }
            }
        }
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: Constants.buttonSpacing) {
            if timer.timerState == .idle {
                // Primary action - uses color to draw attention
                Button(action: { timer.startWorkSession() }) {
                    Label("Start", systemImage: "play.fill")
                        .frame(width: Constants.primaryButtonWidth)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button(action: { timer.togglePause() }) {
                    Label(
                        timer.timerState == .running ? "Pause" : "Resume",
                        systemImage: timer.timerState == .running ? "pause.fill" : "play.fill"
                    )
                    .frame(width: Constants.primaryButtonWidth)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: { timer.reset() }) {
                    Label("Reset", systemImage: "stop.fill")
                        .frame(width: Constants.secondaryButtonWidth)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    // MARK: - Skip Break Button

    private var skipBreakButton: some View {
        Button(action: { timer.reset() }) {
            Label("Skip Break", systemImage: "forward.end.fill")
                .frame(width: 140)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .padding(.top, 10)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: Constants.safeAreaPadding) {
            StatItem(value: "\(appState.totalSessionsCompleted)", label: "Sessions")
            StatDivider()
            StatItem(value: "\(appState.workDuration)m", label: "Work")
            StatDivider()
            StatItem(value: "\(appState.repsRequired)", label: "Reps")
        }
        .padding(Constants.statBarPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.statBarCornerRadius))
    }

    // MARK: - Debug Controls

    #if DEBUG
    private var debugControls: some View {
        Button(action: {
            if timer.timerState == .idle {
                timer.startWorkSession()
            }
            timer.skipToEnd()
        }) {
            Label("DEBUG: Skip to Break", systemImage: "forward.end.fill")
        }
        .buttonStyle(.bordered)
        .tint(.orange)
        .padding(.top, 10)
    }
    #endif
}

// MARK: - Supporting Views

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
    PomodoroView(timer: PomodoroTimer())
        .environmentObject(AppState())
}
