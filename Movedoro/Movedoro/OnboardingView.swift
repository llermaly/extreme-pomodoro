import SwiftUI
import AVFoundation

/// First-time setup wizard
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    @State private var currentStep: Int = 0
    @StateObject private var cameraCapture = CameraCapture()
    @StateObject private var poseDetector = PoseDetector()
    @State private var showPoseOverlay = true
    @State private var cameraPermissionGranted = false
    @State private var cameraPermissionRequested = false

    private let totalSteps = 5

    var body: some View {
        ZStack {
            // Background layer - content shines through glass
            backgroundLayer

            VStack(spacing: 0) {
                // Header with progress - glass styled
                headerView

                // Step content - fixed height container
                Group {
                    switch currentStep {
                    case 0: welcomeStep
                    case 1: workScheduleStep
                    case 2: exerciseStep
                    case 3: cameraCalibrationStep
                    case 4: completeStep
                    default: welcomeStep
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 680)

                Spacer(minLength: 0)

                // Navigation buttons with glass effect
                navigationButtons
            }
        }
        .frame(width: 720, height: 820)
        .onAppear {
            requestCameraPermission()
        }
        .onDisappear {
            cameraCapture.stopCapture()
        }
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
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Setup Movedoro")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(step <= currentStep ? Color.workAccent : Color.secondary.opacity(0.3))
                        .frame(height: 6)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())

            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Spacer()

            if currentStep == totalSteps - 1 {
                Button("Get Started") {
                    cameraCapture.stopCapture()
                    appState.completeOnboarding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else if currentStep == 3 && (appState.exerciseType == "sitToStand" || appState.exerciseType == "standingDesk") {
                if poseDetector.isCalibrated {
                    Button("Next") {
                        nextStep()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    HStack(spacing: 12) {
                        Button("Skip for now") {
                            nextStep()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        if poseDetector.calibrationState == .calibrated || poseDetector.calibrationState == .notCalibrated {
                            Button("Next") {
                                nextStep()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(!poseDetector.isCalibrated)
                        }
                    }
                }
            } else {
                Button("Next") {
                    nextStep()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private func requestCameraPermission() {
        guard !cameraPermissionRequested else { return }
        cameraPermissionRequested = true

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
        @unknown default:
            cameraPermissionGranted = false
        }
    }

    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentStep += 1
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "figure.run")
                .font(.system(size: 100))
                .foregroundStyle(Color.workAccent)

            Text("Welcome to Movedoro")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Stay productive and healthy with enforced exercise breaks")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "clock.fill", title: "Pomodoro Timer", description: "Focus for 25 minutes, then take a break")
                FeatureRow(icon: "figure.stand", title: "Exercise Tracking", description: "Camera tracks your movements in real-time")
                FeatureRow(icon: "lock.fill", title: "Enforced Breaks", description: "Screen locks until you complete your exercise")
            }
            .padding(Constants.cardPadding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
            .padding(.top, 30)

            Spacer()
        }
        .padding(50)
    }

    // MARK: - Step 1: Work Schedule

    private var workScheduleStep: some View {
        VStack(spacing: 30) {
            Text("Your Work Schedule")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Set your pomodoro cycle and working hours")
                .foregroundStyle(.secondary)

            VStack(spacing: 24) {
                // Pomodoro Cycle Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Pomodoro Cycle", systemImage: "timer")
                        .font(.headline)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Work Duration")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach([15, 25, 30, 45, 50], id: \.self) { minutes in
                                    Button("\(minutes)") {
                                        appState.workDuration = minutes
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(appState.workDuration == minutes ? Color.workAccent : .secondary)
                                }
                            }
                        }

                        Divider()
                            .frame(height: 60)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Break Duration")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach([3, 5, 10, 15], id: \.self) { minutes in
                                    Button("\(minutes)") {
                                        appState.breakDuration = minutes
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(appState.breakDuration == minutes ? Color.breakAccent : .secondary)
                                }
                            }
                        }
                    }

                    // Cycle preview
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(Color.workAccent)
                        Text("\(appState.workDuration) min work + \(appState.breakDuration) min break = \(appState.workDuration + appState.breakDuration) min cycle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding(Constants.cardPadding)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))

                // Working Hours Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Working Hours", systemImage: "clock")
                        .font(.headline)

                    HStack(spacing: 30) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Time")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("", selection: $appState.workStartHour) {
                                ForEach(5..<13) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                        }

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("End Time")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Picker("", selection: $appState.workEndHour) {
                                ForEach(14..<24) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                        }
                    }

                    // Day preview
                    HStack {
                        Image(systemName: "calendar.day.timeline.left")
                            .foregroundStyle(Color.workAccent)
                        Text("\(appState.totalPomodoroSlots) pomodoro slots per day (\(appState.workEndHour - appState.workStartHour) hours)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding(Constants.cardPadding)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
            }
            .frame(maxWidth: 500)

            Spacer()
        }
        .padding(40)
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: 0)) ?? Date()
        return formatter.string(from: date)
    }

    // MARK: - Step 2: Exercise

    private var exerciseStep: some View {
        VStack(spacing: 24) {
            Text("Choose Your Exercise")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Select the exercise you want to do during breaks")
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ExerciseOption(
                    title: "Sit-to-Stand",
                    description: "Stand up from sitting position. Great for desk workers. Requires calibration.",
                    icon: "figure.stand",
                    isSelected: appState.exerciseType == "sitToStand"
                ) {
                    appState.exerciseType = "sitToStand"
                }

                ExerciseOption(
                    title: "Standing Desk",
                    description: "Continuous sit/stand posture monitoring. Track your standing desk usage.",
                    icon: "desktopcomputer",
                    isSelected: appState.exerciseType == "standingDesk",
                    isComingSoon: true
                ) {
                    appState.exerciseType = "standingDesk"
                }

                ExerciseOption(
                    title: "Squats",
                    description: "Full squat movements. More intense workout.",
                    icon: "figure.strengthtraining.traditional",
                    isSelected: appState.exerciseType == "squats",
                    isComingSoon: true
                ) {
                    appState.exerciseType = "squats"
                }

                ExerciseOption(
                    title: "Jumping Jacks",
                    description: "Cardio exercise with arm movements.",
                    icon: "figure.jumprope",
                    isSelected: appState.exerciseType == "jumpingJacks",
                    isComingSoon: true
                ) {
                    appState.exerciseType = "jumpingJacks"
                }

                ExerciseOption(
                    title: "Arm Raises",
                    description: "Simple arm raises. Low impact option.",
                    icon: "figure.arms.open",
                    isSelected: appState.exerciseType == "armRaises",
                    isComingSoon: true
                ) {
                    appState.exerciseType = "armRaises"
                }
            }
            .frame(maxWidth: 500)

            // Reps configuration
            VStack(spacing: 12) {
                Label("Reps per Break", systemImage: "number")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach([5, 10, 15, 20, 25, 30], id: \.self) { reps in
                        Button("\(reps)") {
                            appState.repsRequired = reps
                        }
                        .buttonStyle(.bordered)
                        .tint(appState.repsRequired == reps ? Color.workAccent : .secondary)
                    }
                }

                Text("You'll need to complete \(appState.repsRequired) reps to finish each break")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(Constants.cardPadding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
            .frame(maxWidth: 500)

            Spacer()
        }
        .padding(40)
    }

    // MARK: - Step 3: Camera Calibration

    private var cameraCalibrationStep: some View {
        VStack(spacing: 12) {
            Text((appState.exerciseType == "sitToStand" || appState.exerciseType == "standingDesk") ? "Camera & Calibration" : "Camera Setup")
                .font(.title)
                .fontWeight(.bold)

            Text((appState.exerciseType == "sitToStand" || appState.exerciseType == "standingDesk")
                 ? "Select your camera and calibrate your sitting/standing positions"
                 : "Select the camera you'll use for exercise tracking")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                if cameraCapture.isCapturing {
                    ZStack {
                        CameraPreviewView(cameraCapture: cameraCapture)

                        if showPoseOverlay {
                            PoseOverlayView(pose: poseDetector.currentPose, imageSize: CGSize(width: 520, height: 390))
                        }
                    }
                    .frame(width: 520, height: 390)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius))
                } else {
                    RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius)
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 520, height: 390)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                                Text("Starting camera...")
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cameraPreviewCornerRadius)
                    .strokeBorder(borderColor.opacity(0.6), lineWidth: 3)
            )

            HStack(spacing: 20) {
                if !cameraCapture.availableCameras.isEmpty {
                    Picker("Camera", selection: Binding(
                        get: { cameraCapture.selectedCamera },
                        set: { if let cam = $0 { cameraCapture.selectCamera(cam) } }
                    )) {
                        ForEach(cameraCapture.availableCameras, id: \.uniqueID) { camera in
                            Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                        }
                    }
                    .frame(width: 250)
                }

                if cameraCapture.isCapturing {
                    HStack {
                        Circle()
                            .fill(poseDetector.isPersonDetected ? Color.breakAccent : Color.orange)
                            .frame(width: 12, height: 12)
                        Text(poseDetector.isPersonDetected ? "Person detected" : "Stand in front of camera")
                            .font(.caption)
                            .foregroundStyle(poseDetector.isPersonDetected ? Color.breakAccent : .orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Toggle("Skeleton", isOn: $showPoseOverlay)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
            }

            if appState.exerciseType == "sitToStand" || appState.exerciseType == "standingDesk" {
                calibrationSection
            } else {
                nonCalibrationSection
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .onAppear {
            cameraCapture.loadAvailableCameras()
            if !cameraCapture.isCapturing {
                cameraCapture.poseDetector = poseDetector
                cameraCapture.startCapture()
            } else if cameraCapture.poseDetector == nil {
                cameraCapture.poseDetector = poseDetector
            }
        }
    }

    private var calibrationSection: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.vertical, 4)

            HStack(spacing: 20) {
                HStack {
                    Circle()
                        .fill(poseDetector.isCalibrated ? Color.breakAccent : Color.orange)
                        .frame(width: 14, height: 14)
                    Text(poseDetector.isCalibrated ? "Calibrated" : "Not Calibrated")
                        .font(.headline)
                        .foregroundStyle(poseDetector.isCalibrated ? Color.breakAccent : .orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())

                if cameraCapture.isCapturing {
                    HStack {
                        Circle()
                            .fill(poseDetector.isPersonDetected ? Color.breakAccent : Color.red)
                            .frame(width: 10, height: 10)
                        Text(poseDetector.poseDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if poseDetector.calibrationState != .notCalibrated &&
               poseDetector.calibrationState != .calibrated {
                VStack(spacing: 8) {
                    Text(poseDetector.calibrationMessage)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.workAccent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

                    Button("Cancel Calibration") {
                        poseDetector.cancelCalibration()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            } else if poseDetector.isCalibrated {
                HStack(spacing: 16) {
                    Text("Calibration Complete!")
                        .font(.headline)
                        .foregroundStyle(Color.breakAccent)

                    Text("Sit Y: \(String(format: "%.3f", poseDetector.sittingHipY)) | Stand Y: \(String(format: "%.3f", poseDetector.standingHipY))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Re-Calibrate") {
                        poseDetector.startCalibration()
                    }
                    .buttonStyle(.bordered)
                    .tint(.purple)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            } else {
                Button("Start Calibration") {
                    poseDetector.startCalibration()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .controlSize(.large)
            }
        }
    }

    private var nonCalibrationSection: some View {
        Group {
            if cameraCapture.isCapturing && poseDetector.isPersonDetected {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.breakAccent)
                    Text("Camera ready!")
                        .font(.headline)
                        .foregroundStyle(Color.breakAccent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }

    private var borderColor: Color {
        if appState.exerciseType == "sitToStand" || appState.exerciseType == "standingDesk" {
            return poseDetector.isCalibrated ? Color.breakAccent : Color.workAccent
        } else {
            return poseDetector.isPersonDetected ? Color.breakAccent : Color.secondary
        }
    }

    // MARK: - Step 4: Complete

    private var completeStep: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(Color.breakAccent)

            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Here's a summary of your settings:")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "clock")
                        .frame(width: 30)
                    Text("Cycle: \(appState.workDuration) min work / \(appState.breakDuration) min break")
                }
                HStack {
                    Image(systemName: "calendar")
                        .frame(width: 30)
                    Text("Hours: \(formatHour(appState.workStartHour)) - \(formatHour(appState.workEndHour))")
                }
                HStack {
                    Image(systemName: "square.grid.3x3")
                        .frame(width: 30)
                    Text("\(appState.totalPomodoroSlots) pomodoros per day")
                }
                HStack {
                    Image(systemName: "figure.stand")
                        .frame(width: 30)
                    Text("Exercise: \(exerciseDisplayName)")
                }
                HStack {
                    Image(systemName: "number")
                        .frame(width: 30)
                    Text("Reps: \(appState.repsRequired) per break")
                }
                HStack {
                    Image(systemName: poseDetector.isCalibrated ? "checkmark.circle.fill" : "exclamationmark.circle")
                        .foregroundStyle(poseDetector.isCalibrated ? Color.breakAccent : .orange)
                        .frame(width: 30)
                    Text(poseDetector.isCalibrated ? "Calibration: Complete" : "Calibration: Skipped (can do in settings)")
                        .foregroundColor(poseDetector.isCalibrated ? .primary : .orange)
                }
            }
            .font(.title3)
            .padding(Constants.cardPadding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))

            Spacer()
        }
        .padding(50)
        .onAppear {
            cameraCapture.stopCapture()
        }
    }

    private var exerciseDisplayName: String {
        switch appState.exerciseType {
        case "sitToStand": return "Sit-to-Stand"
        case "standingDesk": return "Standing Desk"
        case "squats": return "Squats"
        case "jumpingJacks": return "Jumping Jacks"
        case "armRaises": return "Arm Raises"
        default: return appState.exerciseType
        }
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color.workAccent)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ExerciseOption: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    var isComingSoon: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            if !isComingSoon {
                action()
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .frame(width: 50)
                    .foregroundStyle(isComingSoon ? .tertiary : .primary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(isComingSoon ? .tertiary : .primary)
                        if isComingSoon {
                            Text("Soon")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(isComingSoon ? .tertiary : .secondary)
                }

                Spacer()

                if isSelected && !isComingSoon {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.workAccent)
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
        .disabled(isComingSoon)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Constants.sessionItemCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Constants.sessionItemCornerRadius)
                .strokeBorder(isSelected && !isComingSoon ? Color.workAccent : Color.clear, lineWidth: 2)
        )
        .opacity(isComingSoon ? 0.6 : 1.0)
    }
}

struct QuickPresetButton: View {
    let value: Int
    let current: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(value)")
                .fontWeight(.medium)
                .frame(width: 50, height: 40)
        }
        .buttonStyle(.bordered)
        .tint(value == current ? Color.workAccent : .secondary)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
