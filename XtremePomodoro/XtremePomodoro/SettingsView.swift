import SwiftUI
import AppKit
import AVFoundation
import Speech

/// Basic settings view
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechRecognition = SpeechRecognitionService(deferLocaleSetup: true)
    @State private var lastRecognizedText = ""
    /// TTS service instance - must be retained to prevent deallocation during speech
    @State private var ttsService: NativeTTSService?
    /// Selected voice identifier (empty = auto)
    @State private var selectedVoiceIdentifier = ""
    /// Available premium/enhanced voices
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

            Divider()

            Form {
                // Timer Settings
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

                // Exercise Settings
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

                // Pose Detection Settings
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
                                .foregroundColor(.secondary)
                            Text("3D detection provides body height estimation and distance from camera. Works best with depth-enabled cameras (LiDAR).")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Voice Settings
                Section("Voice") {
                    // Voice picker for premium/enhanced voices
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
                                .foregroundColor(.secondary)
                        }
                    }

                    Text("Only showing Premium/Enhanced voices. Download more in System Settings > Accessibility > Spoken Content > System Voice > Manage Voices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Voice Test (Interactive)
                Section("Voice Test") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Locale info
                        HStack {
                            Text("Recognition Language:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(speechRecognition.selectedLocale.identifier(.bcp47))
                                .font(.caption)
                                .fontWeight(.medium)
                        }

                        // Status and control
                        HStack {
                            Circle()
                                .fill(speechRecognition.isListening ? Color.red : Color.gray)
                                .frame(width: 12, height: 12)

                            Text(speechRecognition.isListening ? "Listening..." : "Not listening")
                                .foregroundColor(speechRecognition.isListening ? .red : .secondary)

                            Spacer()

                            Button(speechRecognition.isListening ? "Stop" : "Start Listening") {
                                Task {
                                    if speechRecognition.isListening {
                                        await speechRecognition.stopListening()
                                        // Acknowledge what was said
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
                            .tint(speechRecognition.isListening ? .red : .blue)
                        }

                        // Real-time transcript
                        if speechRecognition.isListening || !speechRecognition.currentTranscript.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("You said:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(speechRecognition.currentTranscript.isEmpty ? "..." : speechRecognition.currentTranscript)
                                    .font(.body)
                                    .foregroundColor(speechRecognition.volatileTranscript.isEmpty ? .primary : .purple)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }

                        // Last response
                        if !lastRecognizedText.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Trainer heard:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("\"\(lastRecognizedText)\"")
                                    .font(.body)
                                    .italic()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }

                        // Error message
                        if let error = speechRecognition.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        // Download progress
                        if let progress = speechRecognition.downloadProgress {
                            ProgressView(progress)
                                .progressViewStyle(.linear)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Advanced
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
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                // Debug
                #if DEBUG
                Section("Debug") {
                    Button("Reset Onboarding") {
                        appState.resetOnboarding()
                        dismiss()
                    }
                    .foregroundColor(.red)

                    HStack {
                        Text("Sessions Completed")
                        Spacer()
                        Text("\(appState.totalSessionsCompleted)")
                            .foregroundColor(.secondary)
                    }
                }
                #endif
            }
            .formStyle(.grouped)
        }
        .frame(width: 450, height: 750)
        .onChange(of: poseDetectionMode) { _, newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: "poseDetectionMode")
        }
    }

    private func speakResponse(to text: String) {
        // Create and retain the TTS service
        ttsService = NativeTTSService()
        let response = "I heard you say: \(text)"
        ttsService?.speak(response)
    }

    private func testVoice() {
        ttsService = NativeTTSService()

        // If a specific voice is selected, use it
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
