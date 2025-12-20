import SwiftUI
import AppKit
import AVFoundation
import Speech

/// Settings view with Liquid Glass styling
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechRecognition = SpeechRecognitionService(deferLocaleSetup: true)
    @State private var lastRecognizedText = ""
    @State private var ttsService: NativeTTSService?
    @State private var selectedVoiceIdentifier = ""
    @Namespace private var glassNamespace

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
            // Header with glass toolbar
            headerView

            Divider()

            // Form content - uses built-in SwiftUI components per Liquid Glass guidelines
            Form {
                timerSection
                exerciseSection
                poseDetectionSection
                voiceSection
                voiceTestSection
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

            // Primary action button - uses color per Liquid Glass guidelines
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .glassEffectID("doneButton", in: glassNamespace)
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
                    Text("Squats").tag("squats")
                    Text("Jumping Jacks").tag("jumpingJacks")
                    Text("Arm Raises").tag("armRaises")
                }
                .frame(width: 150)
            }

            HStack {
                Text("Reps Required")
                Spacer()
                Stepper("\(appState.repsRequired)", value: $appState.repsRequired, in: 3...30)
                    .frame(width: 120)
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
            .buttonStyle(.glass)

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

    // MARK: - Voice Test Section

    private var voiceTestSection: some View {
        Section("Voice Test") {
            VStack(alignment: .leading, spacing: 12) {
                // Locale info
                HStack {
                    Text("Recognition Language:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(speechRecognition.selectedLocale.identifier(.bcp47))
                        .font(.caption)
                        .fontWeight(.medium)
                }

                // Status and control
                listeningStatusView

                // Real-time transcript
                if speechRecognition.isListening || !speechRecognition.currentTranscript.isEmpty {
                    transcriptView
                }

                // Last response
                if !lastRecognizedText.isEmpty {
                    lastResponseView
                }

                // Error message
                if let error = speechRecognition.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Download progress
                if let progress = speechRecognition.downloadProgress {
                    ProgressView(progress)
                        .progressViewStyle(.linear)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var listeningStatusView: some View {
        HStack {
            Circle()
                .fill(speechRecognition.isListening ? Color.red : Color.secondary)
                .frame(width: Constants.statusIndicatorSize, height: Constants.statusIndicatorSize)

            Text(speechRecognition.isListening ? "Listening..." : "Not listening")
                .foregroundStyle(speechRecognition.isListening ? .red : .secondary)

            Spacer()

            Button(speechRecognition.isListening ? "Stop" : "Start Listening") {
                Task {
                    if speechRecognition.isListening {
                        await speechRecognition.stopListening()
                        if !speechRecognition.finalTranscript.isEmpty {
                            lastRecognizedText = speechRecognition.finalTranscript
                            speakResponse(to: lastRecognizedText)
                        }
                    } else {
                        do {
                            try await speechRecognition.startListening()
                        } catch {
                            speechRecognition.errorMessage = error.localizedDescription
                            print("Failed to start listening: \(error)")
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(speechRecognition.isListening ? .red : Color.workAccent)
        }
    }

    private var transcriptView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("You said:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(speechRecognition.currentTranscript.isEmpty ? "..." : speechRecognition.currentTranscript)
                .font(.body)
                .foregroundColor(speechRecognition.volatileTranscript.isEmpty ? .primary : .purple)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var lastResponseView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Trainer heard:")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\"\(lastRecognizedText)\"")
                .font(.body)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.workAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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

    private func speakResponse(to text: String) {
        ttsService = NativeTTSService()
        let response = "I heard you say: \(text)"
        ttsService?.speak(response)
    }

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
