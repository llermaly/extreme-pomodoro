import SwiftUI
import AVFoundation

/// Fullscreen exercise overlay
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
            // Background layer
            backgroundLayer

            VStack(spacing: Constants.standardPadding) {
                // Header
                headerView
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                // Camera preview
                cameraPreviewLayer

                // Status bar
                statusBarView
                    .padding(.horizontal, 40)

                // Completion or instructions
                instructionsView

                Spacer()

                // DEBUG controls
                #if DEBUG
                debugControlsView
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
                poseDetector.speakAfterCurrent("Great job! All reps complete. Click continue to get back to work.")
            }
        }
    }

    // MARK: - Background Layer

    private var backgroundLayer: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    isComplete ? Color.breakAccent.opacity(0.15) : Color.workAccent.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Break Time!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Complete your exercises to continue working")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            repCounterView
        }
    }

    private var repCounterView: some View {
        HStack(spacing: 8) {
            Text("\(repsCompleted)")
                .font(.system(size: Constants.repCounterFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(isComplete ? Color.breakAccent : .white)

            Text("/ \(repsRequired)")
                .font(.title)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Camera Preview

    private var cameraPreviewLayer: some View {
        ZStack {
            if cameraCapture.isCapturing {
                ZStack {
                    CameraPreviewView(cameraCapture: cameraCapture)

                    if showPoseOverlay {
                        PoseOverlayView(pose: poseDetector.currentPose, imageSize: CGSize(width: 800, height: 600))
                    }

                    if poseDetector.gestureHoldProgress > 0 {
                        gestureProgressIndicator
                    }

                    if isComplete {
                        completionOverlay
                    }
                }
                .frame(maxWidth: Constants.cameraPreviewMaxWidth, maxHeight: Constants.cameraPreviewMaxHeight)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius))
            } else {
                cameraPlaceholder
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius)
                .strokeBorder(
                    isComplete ? Color.breakAccent.opacity(0.6) : Color.workAccent.opacity(0.4),
                    lineWidth: 3
                )
        )
    }

    private var gestureProgressIndicator: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: poseDetector.gestureHoldProgress)
                        .stroke(Color.cyan, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(max(1, Int(ceil(2.0 * (1.0 - poseDetector.gestureHoldProgress)))))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(30)
            }
        }
    }

    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)

            VStack(spacing: 20) {
                Text("Great job!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.breakAccent)

                Text("\(repsCompleted) reps completed")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))

                Button(action: { completeExercise() }) {
                    Label("Continue Working", systemImage: "arrow.right.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color.breakAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var cameraPlaceholder: some View {
        RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius)
            .fill(Color.glassBackground)
            .frame(maxWidth: Constants.cameraPreviewMaxWidth, maxHeight: Constants.cameraPreviewMaxHeight)
            .overlay(
                VStack(spacing: 20) {
                    if isSettingUp {
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.white)
                        Text("Starting camera...")
                            .font(.title2)
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text("Camera is off")
                            .font(.title2)
                            .foregroundStyle(.white)

                        Button(action: { startCamera() }) {
                            Label("Start Camera", systemImage: "camera")
                                .font(.title3)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            )
    }

    // MARK: - Status Bar

    private var statusBarView: some View {
        HStack(spacing: 20) {
            StatusIndicator(
                isActive: cameraCapture.isCapturing,
                activeLabel: "Camera on",
                inactiveLabel: "Camera off",
                activeColor: .green,
                inactiveColor: .red
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())

            if cameraCapture.isCapturing {
                StatusIndicator(
                    isActive: poseDetector.isPersonDetected,
                    activeLabel: poseDetector.poseDescription,
                    inactiveLabel: poseDetector.poseDescription,
                    activeColor: .green,
                    inactiveColor: .orange
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

                if poseDetector.currentExercise == .sitToStand && poseDetector.isCalibrated {
                    exerciseStateIndicator
                }

                if poseDetector.detectionMode == .mode3D && poseDetector.isPersonDetected {
                    mode3DInfo
                }
            }

            Spacer()

            if cameraCapture.isCapturing {
                controlsGroup
            } else if !isSettingUp {
                Button(action: { startCamera() }) {
                    Label("Start Camera", systemImage: "camera")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var exerciseStateIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(stateColor(for: poseDetector.exerciseState))
                .frame(width: Constants.statusIndicatorSize, height: Constants.statusIndicatorSize)
            Text(poseDetector.exerciseState.rawValue)
                .fontWeight(.medium)
                .foregroundStyle(stateColor(for: poseDetector.exerciseState))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var mode3DInfo: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "figure.stand")
                    .foregroundStyle(.cyan)
                Text(poseDetector.bodyHeight)
                    .foregroundStyle(.cyan)
                    .font(.caption)
            }

            HStack(spacing: 4) {
                Image(systemName: "arrow.left.and.right")
                    .foregroundStyle(.cyan)
                Text(poseDetector.cameraDistance)
                    .foregroundStyle(.cyan)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var controlsGroup: some View {
        HStack(spacing: 8) {
            Text(poseDetector.detectionMode.rawValue)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(poseDetector.detectionMode == .mode3D ? Color.cyan.opacity(0.3) : Color.green.opacity(0.3))
                .foregroundStyle(poseDetector.detectionMode == .mode3D ? .cyan : .green)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Toggle("Skeleton", isOn: $showPoseOverlay)
                .toggleStyle(.button)
                .buttonStyle(.bordered)
        }
    }

    // MARK: - Instructions View

    @ViewBuilder
    private var instructionsView: some View {
        if isComplete {
            completionView
        } else if cameraCapture.isCapturing {
            if poseDetector.currentExercise == .sitToStand {
                if !poseDetector.isCalibrated {
                    calibrationView
                } else {
                    remainingRepsLabel
                }
            } else {
                remainingRepsLabel
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 15) {
            Text("Great job!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.breakAccent)

            Button(action: { completeExercise() }) {
                Label("Continue Working", systemImage: "arrow.right.circle.fill")
                    .font(.title2)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.breakAccent)
            .controlSize(.large)
        }
        .padding(.top, 10)
    }

    private var calibrationView: some View {
        VStack(spacing: 12) {
            Text("Calibration needed for accurate tracking")
                .foregroundStyle(.orange)

            if poseDetector.calibrationState != .notCalibrated &&
               poseDetector.calibrationState != .calibrated {
                Text(poseDetector.calibrationMessage)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.workAccent)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))

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
    }

    private var remainingRepsLabel: some View {
        Text("Complete \(repsRequired - repsCompleted) more reps to continue")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.white.opacity(0.9))
            .padding()
            .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Helper Methods

    private func setupExercise() {
        guard !hasSetupCompleted else {
            print("[ExerciseOverlay] Setup already completed, ignoring duplicate onAppear")
            return
        }
        hasSetupCompleted = true

        isSettingUp = true
        hasAnnouncedCompletion = false

        let exerciseType: PoseDetector.ExerciseType
        switch appState.exerciseType {
        case "sitToStand": exerciseType = .sitToStand
        case "squats": exerciseType = .squats
        case "jumpingJacks": exerciseType = .jumpingJacks
        case "armRaises": exerciseType = .armRaises
        default: exerciseType = .sitToStand
        }
        poseDetector.setExercise(exerciseType)

        let exerciseName = exerciseType.rawValue
        poseDetector.speakAfterCurrent("Break time! Complete \(appState.repsRequired) \(exerciseName) reps to continue working.")

        poseDetector.onCapturePhoto = { [weak photoManager] repNumber, position in
            guard let photoManager = photoManager,
                  let image = cameraCapture.capturePhoto() else { return }
            let pos: ExercisePhoto.Position = position == "sitting" ? .sitting : .standing
            photoManager.capturePhoto(image: image, repNumber: repNumber, position: pos)
        }

        poseDetector.onRepCompleted = { repNumber in }

        photoManager.startSession()
        appState.currentPhotoSessionPath = photoManager.sessionPath

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
        cameraCapture.stopCapture()
        appState.completeExercise()
    }

    private func stateColor(for state: PoseDetector.ExerciseState) -> Color {
        switch state {
        case .standing: return .green
        case .goingDown: return .orange
        case .holdingSit: return .yellow
        case .sitting: return Color.workAccent
        case .goingUp: return .purple
        }
    }

    // MARK: - Debug View

    #if DEBUG
    private var debugControlsView: some View {
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
                    .tint(Color.workAccent)
                }

                Toggle("Debug", isOn: $showDebugInfo)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                    .tint(.purple)
            }

            if showDebugInfo {
                calibrationDebugView
            }
        }
        .padding(.bottom, 20)
    }

    private var calibrationDebugView: some View {
        let currentHipY = poseDetector.currentPose?.hipY
        let positionPercent = poseDetector.currentPose.flatMap { poseDetector.getPositionPercent($0) }
        let inSitting = poseDetector.currentPose.map { poseDetector.isInSittingZone($0) } ?? false
        let inStanding = poseDetector.currentPose.map { poseDetector.isInStandingZone($0) } ?? false
        let pose = poseDetector.currentPose

        return VStack(alignment: .leading, spacing: 8) {
            Text("CALIBRATION DEBUG")
                .font(.headline)
                .foregroundStyle(.yellow)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("JOINTS").font(.caption2).foregroundStyle(.gray)
                    HStack(spacing: 4) {
                        jointIndicator("LH", detected: pose?.joints[.leftHip] != nil)
                        jointIndicator("RH", detected: pose?.joints[.rightHip] != nil)
                    }
                    HStack(spacing: 4) {
                        jointIndicator("LS", detected: pose?.joints[.leftShoulder] != nil)
                        jointIndicator("RS", detected: pose?.joints[.rightShoulder] != nil)
                    }
                    HStack(spacing: 4) {
                        jointIndicator("LW", detected: pose?.joints[.leftWrist] != nil)
                        jointIndicator("RW", detected: pose?.joints[.rightWrist] != nil)
                    }
                }

                Divider().frame(height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(poseDetector.isCalibrated ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text("Calibrated: \(poseDetector.isCalibrated ? "YES" : "NO")")
                    }
                    Text("State: \(String(describing: poseDetector.calibrationState))")
                        .font(.caption)
                    if pose?.handsCloseTogether == true {
                        Text("Hands Together!")
                            .foregroundStyle(.cyan)
                            .fontWeight(.bold)
                    }
                }

                Divider().frame(height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Sit Y: \(String(format: "%.4f", poseDetector.sittingHipY))")
                    Text("Stand Y: \(String(format: "%.4f", poseDetector.standingHipY))")
                    Text("Range: \(String(format: "%.4f", poseDetector.standingHipY - poseDetector.sittingHipY))")
                }

                Divider().frame(height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    if let hipY = currentHipY {
                        Text("Current Y: \(String(format: "%.4f", hipY))")
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    } else {
                        Text("Current Y: -- (NO HIPS!)")
                            .foregroundStyle(.red)
                            .fontWeight(.bold)
                    }

                    if let percent = positionPercent {
                        HStack {
                            Text("Pos:")
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.glassBackground)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(percent > 50 ? Color.green : Color.workAccent)
                                        .frame(width: geo.size.width * CGFloat(percent / 100))
                                }
                            }
                            .frame(width: 100, height: 12)
                            Text("\(Int(percent))%")
                        }
                    }
                }

                Divider().frame(height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(inSitting ? Color.workAccent : Color.glassBackground)
                            .frame(width: 14, height: 14)
                        Text("In Sit Zone")
                            .foregroundStyle(inSitting ? Color.workAccent : .secondary)
                    }
                    HStack {
                        Circle()
                            .fill(inStanding ? Color.green : Color.glassBackground)
                            .frame(width: 14, height: 14)
                        Text("In Stand Zone")
                            .foregroundStyle(inStanding ? .green : .secondary)
                    }
                }

                Divider().frame(height: 60)

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
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .strokeBorder(Color.yellow.opacity(0.5), lineWidth: 1)
        )
        .foregroundStyle(.white)
    }

    private func jointIndicator(_ label: String, detected: Bool) -> some View {
        Text(label)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(detected ? Color.green : Color.red.opacity(0.7))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
    #endif
}

// MARK: - Status Indicator Component

private struct StatusIndicator: View {
    let isActive: Bool
    let activeLabel: String
    let inactiveLabel: String
    let activeColor: Color
    let inactiveColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? activeColor : inactiveColor)
                .frame(width: Constants.statusIndicatorSize, height: Constants.statusIndicatorSize)
            Text(isActive ? activeLabel : inactiveLabel)
                .foregroundStyle(isActive ? activeColor : inactiveColor)
        }
    }
}

#Preview {
    ExerciseOverlayView()
        .environmentObject(AppState())
}
