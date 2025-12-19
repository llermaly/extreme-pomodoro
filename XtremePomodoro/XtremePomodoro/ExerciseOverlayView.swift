import SwiftUI
import AVFoundation

/// Fullscreen exercise overlay that blocks the screen during breaks
struct ExerciseOverlayView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var cameraCapture = CameraCapture()
    @StateObject private var poseDetector = PoseDetector()
    @StateObject private var photoManager = SessionPhotoManager()

    @State private var showPoseOverlay = true
    @State private var isSettingUp = true
    @State private var hasAnnouncedCompletion = false
    @State private var showDebugInfo = false
    @State private var hasSetupCompleted = false

    var repsRequired: Int { appState.repsRequired }
    var repsCompleted: Int { poseDetector.exerciseCount }
    var isComplete: Bool { repsCompleted >= repsRequired }

    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Break Time!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Complete your exercises to continue working")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Rep progress
                    HStack(spacing: 8) {
                        Text("\(repsCompleted)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(isComplete ? .green : .white)

                        Text("/ \(repsRequired)")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                // Camera preview
                ZStack {
                    if cameraCapture.isCapturing {
                        ZStack {
                            CameraPreviewView(cameraCapture: cameraCapture)

                            if showPoseOverlay {
                                PoseOverlayView(pose: poseDetector.currentPose, imageSize: CGSize(width: 800, height: 600))
                            }
                        }
                        .frame(maxWidth: 800, maxHeight: 600)
                        .cornerRadius(16)
                    } else {
                        // Camera not running - show placeholder with start button
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: 800, maxHeight: 600)
                            .overlay(
                                VStack(spacing: 20) {
                                    if isSettingUp {
                                        ProgressView()
                                            .scaleEffect(2)
                                            .tint(.white)
                                        Text("Starting camera...")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)

                                        Text("Camera is off")
                                            .font(.title2)
                                            .foregroundColor(.white)

                                        Button(action: { startCamera() }) {
                                            Label("Start Camera", systemImage: "camera")
                                                .font(.title3)
                                                .padding()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.blue)
                                    }
                                }
                            )
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isComplete ? Color.green : Color.blue, lineWidth: 4)
                )

                // Status bar
                HStack(spacing: 30) {
                    // Camera status
                    HStack {
                        Circle()
                            .fill(cameraCapture.isCapturing ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(cameraCapture.isCapturing ? "Camera on" : "Camera off")
                            .foregroundColor(cameraCapture.isCapturing ? .green : .red)
                    }

                    if cameraCapture.isCapturing {
                        Divider()
                            .frame(height: 20)
                            .background(Color.gray)

                        // Pose status
                        HStack {
                            Circle()
                                .fill(poseDetector.isPersonDetected ? Color.green : Color.orange)
                                .frame(width: 12, height: 12)
                            Text(poseDetector.poseDescription)
                                .foregroundColor(.white)
                        }

                        // Exercise state (if calibrated)
                        if poseDetector.currentExercise == .sitToStand && poseDetector.isCalibrated {
                            Divider()
                                .frame(height: 20)
                                .background(Color.gray)

                            HStack {
                                Circle()
                                    .fill(stateColor(for: poseDetector.exerciseState))
                                    .frame(width: 12, height: 12)
                                Text(poseDetector.exerciseState.rawValue)
                                    .fontWeight(.medium)
                                    .foregroundColor(stateColor(for: poseDetector.exerciseState))
                            }
                        }

                        // 3D mode info
                        if poseDetector.detectionMode == .mode3D && poseDetector.isPersonDetected {
                            Divider()
                                .frame(height: 20)
                                .background(Color.gray)

                            HStack(spacing: 8) {
                                // Body height
                                HStack(spacing: 2) {
                                    Image(systemName: "figure.stand")
                                        .foregroundColor(.cyan)
                                    Text(poseDetector.bodyHeight)
                                        .foregroundColor(.cyan)
                                        .font(.caption)
                                }

                                // Distance
                                HStack(spacing: 2) {
                                    Image(systemName: "arrow.left.and.right")
                                        .foregroundColor(.cyan)
                                    Text(poseDetector.cameraDistance)
                                        .foregroundColor(.cyan)
                                        .font(.caption)
                                }
                            }
                        }
                    }

                    Spacer()

                    // Skeleton toggle and mode indicator
                    if cameraCapture.isCapturing {
                        HStack(spacing: 8) {
                            // Mode badge
                            Text(poseDetector.detectionMode.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(poseDetector.detectionMode == .mode3D ? Color.cyan.opacity(0.3) : Color.green.opacity(0.3))
                                .foregroundColor(poseDetector.detectionMode == .mode3D ? .cyan : .green)
                                .cornerRadius(6)

                            Toggle("Skeleton", isOn: $showPoseOverlay)
                                .toggleStyle(.button)
                                .tint(.gray)
                        }
                    }

                    // Manual camera start if not capturing
                    if !cameraCapture.isCapturing && !isSettingUp {
                        Button(action: { startCamera() }) {
                            Label("Start Camera", systemImage: "camera")
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                .padding(.horizontal, 40)

                // Completion message or instructions
                if isComplete {
                    VStack(spacing: 15) {
                        Text("Great job!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        Button(action: { completeExercise() }) {
                            Label("Continue Working", systemImage: "arrow.right.circle.fill")
                                .font(.title2)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                    }
                    .padding(.top, 10)
                } else if cameraCapture.isCapturing {
                    // Show instructions based on calibration status
                    if poseDetector.currentExercise == .sitToStand {
                        if !poseDetector.isCalibrated {
                            VStack(spacing: 12) {
                                Text("Calibration needed for accurate tracking")
                                    .foregroundColor(.orange)

                                if poseDetector.calibrationState != .notCalibrated &&
                                   poseDetector.calibrationState != .calibrated {
                                    Text(poseDetector.calibrationMessage)
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)

                                    Button("Cancel") {
                                        poseDetector.cancelCalibration()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                } else {
                                    Button("Calibrate Now") {
                                        poseDetector.startCalibration()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.purple)
                                    .controlSize(.large)
                                }
                            }
                        } else {
                            Text("Complete \(repsRequired - repsCompleted) more reps to continue")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    } else {
                        Text("Complete \(repsRequired - repsCompleted) more reps to continue")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                Spacer()

                // DEBUG: Skip button and debug info
                #if DEBUG
                VStack(spacing: 12) {
                    HStack {
                        Button(action: {
                            print("[ExerciseOverlay] Skip button pressed")
                            completeExercise()
                        }) {
                            Label("Skip", systemImage: "forward.end.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                        Button(action: {
                            print("[ExerciseOverlay] Fake Rep button pressed")
                            poseDetector.addFakeRep()
                        }) {
                            Label("+1 Rep", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)

                        if !cameraCapture.isCapturing {
                            Button(action: { startCamera() }) {
                                Label("Force Camera", systemImage: "camera")
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }

                        Toggle("Debug", isOn: $showDebugInfo)
                            .toggleStyle(.button)
                            .tint(.purple)
                    }

                    // Debug calibration panel
                    if showDebugInfo {
                        calibrationDebugView
                    }
                }
                .padding(.bottom, 20)
                #endif
            }
        }
        .onAppear {
            setupExercise()
        }
        .onDisappear {
            cameraCapture.stopCapture()
        }
        .onChange(of: isComplete) { oldValue, newValue in
            if newValue && !hasAnnouncedCompletion {
                hasAnnouncedCompletion = true
                // Wait for the last rep speech to finish before announcing completion
                poseDetector.speakAfterCurrent("Great job! All reps complete. Click continue to get back to work.")
            }
        }
    }

    private func setupExercise() {
        // Guard: Don't setup twice
        guard !hasSetupCompleted else {
            print("[ExerciseOverlay] Setup already completed, ignoring duplicate onAppear")
            return
        }
        hasSetupCompleted = true

        isSettingUp = true
        hasAnnouncedCompletion = false

        // Set exercise type from settings
        let exerciseType: PoseDetector.ExerciseType
        switch appState.exerciseType {
        case "sitToStand": exerciseType = .sitToStand
        case "squats": exerciseType = .squats
        case "jumpingJacks": exerciseType = .jumpingJacks
        case "armRaises": exerciseType = .armRaises
        default: exerciseType = .sitToStand
        }
        poseDetector.setExercise(exerciseType)

        // Announce break start
        let exerciseName = exerciseType.rawValue
        poseDetector.speakAfterCurrent("Break time! Complete \(appState.repsRequired) \(exerciseName) reps to continue working.")

        // Setup callbacks
        poseDetector.onCapturePhoto = { [weak photoManager] repNumber, position in
            guard let photoManager = photoManager,
                  let image = cameraCapture.capturePhoto() else { return }
            let pos: ExercisePhoto.Position = position == "sitting" ? .sitting : .standing
            photoManager.capturePhoto(image: image, repNumber: repNumber, position: pos)
        }

        poseDetector.onRepCompleted = { repNumber in
            // Rep completed callback - photo already captured via onCapturePhoto
        }

        // Start photo session and record path for session tracking
        photoManager.startSession()
        appState.currentPhotoSessionPath = photoManager.sessionPath

        // Start camera with slight delay to ensure view is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startCamera()
            isSettingUp = false
        }
    }

    private func startCamera() {
        cameraCapture.loadAvailableCameras()
        cameraCapture.poseDetector = poseDetector
        cameraCapture.startCapture()
    }

    private func completeExercise() {
        // Stop camera first
        cameraCapture.stopCapture()
        // Just update state - the onChange handler in XtremePomodoroApp will dismiss the window
        appState.completeExercise()
    }

    private func stateColor(for state: PoseDetector.ExerciseState) -> Color {
        switch state {
        case .standing: return .green
        case .goingDown: return .orange
        case .holdingSit: return .yellow
        case .sitting: return .blue
        case .goingUp: return .purple
        }
    }

    // MARK: - Debug View

    #if DEBUG
    private var calibrationDebugView: some View {
        let currentHipY = poseDetector.currentPose?.hipY
        let positionPercent = poseDetector.currentPose.flatMap { poseDetector.getPositionPercent($0) }
        let inSitting = poseDetector.currentPose.map { poseDetector.isInSittingZone($0) } ?? false
        let inStanding = poseDetector.currentPose.map { poseDetector.isInStandingZone($0) } ?? false

        return VStack(alignment: .leading, spacing: 8) {
            Text("CALIBRATION DEBUG")
                .font(.headline)
                .foregroundColor(.yellow)

            HStack(spacing: 20) {
                // Calibration status
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(poseDetector.isCalibrated ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text("Calibrated: \(poseDetector.isCalibrated ? "YES" : "NO")")
                    }
                    Text("State: \(String(describing: poseDetector.calibrationState))")
                        .font(.caption)
                }

                Divider().frame(height: 50)

                // Calibrated values
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sit Y: \(String(format: "%.4f", poseDetector.sittingHipY))")
                    Text("Stand Y: \(String(format: "%.4f", poseDetector.standingHipY))")
                    Text("Range: \(String(format: "%.4f", poseDetector.standingHipY - poseDetector.sittingHipY))")
                }

                Divider().frame(height: 50)

                // Current position
                VStack(alignment: .leading, spacing: 4) {
                    if let hipY = currentHipY {
                        Text("Current Y: \(String(format: "%.4f", hipY))")
                            .fontWeight(.bold)
                    } else {
                        Text("Current Y: --")
                    }

                    if let percent = positionPercent {
                        // Visual progress bar
                        HStack {
                            Text("Pos:")
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(percent > 50 ? Color.green : Color.blue)
                                        .frame(width: geo.size.width * CGFloat(percent / 100))
                                }
                            }
                            .frame(width: 100, height: 12)
                            Text("\(Int(percent))%")
                        }
                    }
                }

                Divider().frame(height: 50)

                // Zone status
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(inSitting ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 14)
                        Text("In Sit Zone")
                            .foregroundColor(inSitting ? .blue : .gray)
                    }
                    HStack {
                        Circle()
                            .fill(inStanding ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 14, height: 14)
                        Text("In Stand Zone")
                            .foregroundColor(inStanding ? .green : .gray)
                    }
                }

                Divider().frame(height: 50)

                // Exercise state
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercise: \(poseDetector.currentExercise.rawValue)")
                    HStack {
                        Circle()
                            .fill(stateColor(for: poseDetector.exerciseState))
                            .frame(width: 10, height: 10)
                        Text("State: \(poseDetector.exerciseState.rawValue)")
                            .fontWeight(.bold)
                    }
                }
            }
            .font(.system(size: 12, design: .monospaced))
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
        )
        .foregroundColor(.white)
    }
    #endif
}

#Preview {
    ExerciseOverlayView()
        .environmentObject(AppState())
}
