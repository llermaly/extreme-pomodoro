import SwiftUI

/// Main Pomodoro timer screen
struct PomodoroView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        ZStack {
            // Background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header with settings
                HStack {
                    Text("XtremePomodoro")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: { appState.showSchedule = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("Session History")

                    Button(action: { appState.showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
                .padding(.horizontal)

                Spacer()

                // Session type indicator
                Text(timer.sessionType.label)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(timer.sessionType == .work ? .blue : .green)

                // Timer display with circular progress
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 280, height: 280)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(
                            timer.sessionType == .work ? Color.blue : Color.green,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timer.progress)

                    // Time display
                    VStack(spacing: 4) {
                        Text(timer.timeString)
                            .font(.system(size: 72, weight: .light, design: .rounded))
                            .monospacedDigit()

                        if timer.timerState == .paused {
                            Text("PAUSED")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.bold)
                        }
                    }
                }

                // Control buttons
                HStack(spacing: 20) {
                    if timer.timerState == .idle {
                        Button(action: { timer.startWorkSession() }) {
                            Label("Start", systemImage: "play.fill")
                                .frame(width: 120)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Button(action: { timer.togglePause() }) {
                            Label(
                                timer.timerState == .running ? "Pause" : "Resume",
                                systemImage: timer.timerState == .running ? "pause.fill" : "play.fill"
                            )
                            .frame(width: 120)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button(action: { timer.reset() }) {
                            Label("Reset", systemImage: "stop.fill")
                                .frame(width: 100)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }

                Spacer()

                // Stats
                HStack(spacing: 30) {
                    VStack {
                        Text("\(appState.totalSessionsCompleted)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Sessions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack {
                        Text("\(appState.workDuration)m")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Work")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()
                        .frame(height: 40)

                    VStack {
                        Text("\(appState.repsRequired)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // DEBUG: Skip button for testing
                #if DEBUG
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
                #endif
            }
            .padding(30)
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $appState.showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

#Preview {
    PomodoroView(timer: PomodoroTimer())
        .environmentObject(AppState())
}
