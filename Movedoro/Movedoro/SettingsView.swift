import SwiftUI
import AppKit
import AVFoundation

/// Settings view
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var ttsService: NativeTTSService?
    @State private var selectedVoiceIdentifier = ""

    private var availableVoices: [AVSpeechSynthesisVoice] {
        NativeTTSService.getPremiumVoices()
    }

    @State private var poseDetectionMode: PoseDetectionMode = {
        if let saved = UserDefaults.standard.string(forKey: "poseDetectionMode"),
           let mode = PoseDetectionMode(rawValue: saved) {
            return mode
        }
        return .mode2D
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Form content
            Form {
                timerSection
                exerciseSection
                poseDetectionSection
                voiceSection
                advancedSection

                #if DEBUG
                debugSection
                #endif
            }
            .formStyle(.grouped)
        }
        .frame(width: Constants.settingsWidth, height: Constants.settingsHeight)
        .onChange(of: poseDetectionMode) { _, newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: "poseDetectionMode")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        Section("Timer") {
            HStack {
                Text("Work Duration")
                Spacer()
                Picker("", selection: $appState.workDuration) {
                    ForEach([15, 20, 25, 30, 45, 50, 60], id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .frame(width: 120)
            }

            HStack {
                Text("Break Duration")
                Spacer()
                Picker("", selection: $appState.breakDuration) {
                    ForEach([3, 5, 10, 15], id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .frame(width: 120)
            }
        }
    }

    // MARK: - Exercise Section

    private var exerciseSection: some View {
        Section("Exercise") {
            HStack {
                Text("Exercise Type")
                Spacer()
                Picker("", selection: $appState.exerciseType) {
                    Text("Sit-to-Stand").tag("sitToStand")
                    Text("Standing Desk (Soon)").tag("standingDesk")
                    Text("Squats (Soon)").tag("squats")
                    Text("Jumping Jacks (Soon)").tag("jumpingJacks")
                    Text("Arm Raises (Soon)").tag("armRaises")
                }
                .frame(width: 180)
            }

            if appState.exerciseType == "sitToStand" {
                HStack {
                    Text("Reps Required")
                    Spacer()
                    Stepper("\(appState.repsRequired)", value: $appState.repsRequired, in: 3...30)
                        .frame(width: 120)
                }
            }
        }
    }

    // MARK: - Pose Detection Section

    private var poseDetectionSection: some View {
        Section("Pose Detection") {
            HStack {
                Text("Detection Mode")
                Spacer()
                Picker("", selection: $poseDetectionMode) {
                    Text("2D").tag(PoseDetectionMode.mode2D)
                    Text("3D").tag(PoseDetectionMode.mode3D)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }

            if poseDetectionMode == .mode3D {
                VStack(alignment: .leading, spacing: 4) {
                    Text("3D Mode Info")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("3D detection provides body height estimation and distance from camera. Works best with depth-enabled cameras (LiDAR).")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Voice Section

    private var voiceSection: some View {
        Section("Voice") {
            Picker("Voice", selection: $selectedVoiceIdentifier) {
                Text("Auto (Best Available)").tag("")
                ForEach(availableVoices, id: \.identifier) { voice in
                    Text("\(voice.name) (\(voice.language))")
                        .tag(voice.identifier)
                }
            }

            Button("Preview Voice") {
                testVoice()
            }
            .buttonStyle(.bordered)

            if let tts = ttsService, tts.isSpeaking {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Speaking...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Only showing Premium/Enhanced voices. Download more in System Settings > Accessibility > Spoken Content > System Voice > Manage Voices")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Advanced Section

    private var advancedSection: some View {
        Section {
            Button(action: {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    appState.showAdvancedSettings = true
                }
            }) {
                HStack {
                    Text("Advanced Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Debug Section

    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            Button("Reset Onboarding") {
                appState.resetOnboarding()
                dismiss()
            }
            .foregroundStyle(.red)

            HStack {
                Text("Sessions Completed")
                Spacer()
                Text("\(appState.totalSessionsCompleted)")
                    .foregroundStyle(.secondary)
            }
        }
    }
    #endif

    // MARK: - Helper Methods

    private func testVoice() {
        ttsService = NativeTTSService()

        if !selectedVoiceIdentifier.isEmpty,
           let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier) {
            ttsService?.setVoice(voice)
        }

        ttsService?.speak("Hello! This is how I will coach you during exercise breaks. Great job!")
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
