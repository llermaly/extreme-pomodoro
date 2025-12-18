import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var cameraManager: OBSBOTManager
    @StateObject private var cameraCapture = CameraCapture()
    @StateObject private var poseDetector = PoseDetector()
    @StateObject private var photoManager = SessionPhotoManager()
    @State private var showPoseOverlay = true
    @State private var showGallery = false

    var body: some View {
        HStack(spacing: 0) {
            // Left side - Camera Preview
            VStack {
                ZStack {
                    CameraPreviewView(cameraCapture: cameraCapture)
                        .frame(minWidth: 480, minHeight: 360)

                    if showPoseOverlay {
                        PoseOverlayView(pose: poseDetector.currentPose, imageSize: CGSize(width: 480, height: 360))
                            .frame(minWidth: 480, minHeight: 360)
                    }
                }
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                // Camera selection
                if !cameraCapture.availableCameras.isEmpty {
                    Picker("Camera", selection: Binding(
                        get: { cameraCapture.selectedCamera },
                        set: { if let cam = $0 { cameraCapture.selectCamera(cam) } }
                    )) {
                        ForEach(cameraCapture.availableCameras, id: \.uniqueID) { camera in
                            Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                        }
                    }
                    .frame(width: 300)
                }

                HStack {
                    Button(cameraCapture.isCapturing ? "Stop Preview" : "Start Preview") {
                        if cameraCapture.isCapturing {
                            cameraCapture.stopCapture()
                        } else {
                            cameraCapture.poseDetector = poseDetector
                            cameraCapture.startCapture()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(cameraCapture.isCapturing ? .red : .blue)

                    if cameraCapture.isCapturing {
                        Button("Take Photo") {
                            if let image = cameraCapture.capturePhoto() {
                                savePhoto(image)
                            }
                        }
                        .buttonStyle(.bordered)

                        Toggle("Skeleton", isOn: $showPoseOverlay)
                            .toggleStyle(.button)
                    }
                }
                .padding(.top, 10)

                // Pose Status
                if cameraCapture.isCapturing {
                    HStack {
                        Circle()
                            .fill(poseDetector.isPersonDetected ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(poseDetector.poseDescription)
                            .font(.caption)
                    }
                    .padding(.top, 5)
                }
            }
            .padding()

            Divider()

            // Right side - Controls
            ScrollView {
                VStack(spacing: 20) {
                    Text("XtremePomodoro")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Connection Status
                    HStack {
                        Circle()
                            .fill(cameraManager.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(cameraManager.isConnected ? "SDK Connected" : "SDK Disconnected")
                            .foregroundColor(cameraManager.isConnected ? .green : .red)
                    }

                    if let deviceName = cameraManager.deviceName {
                        Text("Device: \(deviceName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Camera Controls
                    Text("Gimbal Controls")
                        .font(.headline)

                    HStack(spacing: 15) {
                        Button("Left") {
                            cameraManager.moveGimbal(yaw: 0, pitch: -30, roll: 0)
                        }
                        .buttonStyle(.bordered)

                        Button("Center") {
                            cameraManager.moveGimbal(yaw: 0, pitch: 0, roll: 0)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Right") {
                            cameraManager.moveGimbal(yaw: 0, pitch: 30, roll: 0)
                        }
                        .buttonStyle(.bordered)
                    }

                    HStack(spacing: 15) {
                        Button("Up") {
                            cameraManager.moveGimbal(yaw: -30, pitch: 0, roll: 0)
                        }
                        .buttonStyle(.bordered)

                        Button("Down") {
                            cameraManager.moveGimbal(yaw: 30, pitch: 0, roll: 0)
                        }
                        .buttonStyle(.bordered)
                    }

                    Divider()

                    // Camera Position Presets
                    Text("Camera Positions")
                        .font(.headline)

                    HStack(spacing: 15) {
                        VStack(spacing: 8) {
                            Button("Go to Meeting") {
                                cameraManager.moveToPreset(id: 1)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)

                            Button("Save Meeting Pos") {
                                cameraManager.savePreset(id: 1, name: "Meeting")
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }

                        VStack(spacing: 8) {
                            Button("Go to Exercise") {
                                cameraManager.moveToPreset(id: 2)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)

                            Button("Save Exercise Pos") {
                                cameraManager.savePreset(id: 2, name: "Exercise")
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }

                    Divider()

                    // AI Tracking
                    Text("AI Tracking")
                        .font(.headline)

                    HStack(spacing: 15) {
                        Button("Enable") {
                            cameraManager.enableAITracking(true)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button("Disable") {
                            cameraManager.enableAITracking(false)
                        }
                        .buttonStyle(.bordered)
                    }

                    Divider()

                    // Zoom Control
                    Text("Zoom: \(String(format: "%.1fx", cameraManager.zoomLevel))")
                        .font(.headline)

                    Slider(value: $cameraManager.zoomLevel, in: 1.0...2.0, step: 0.1)
                        .frame(width: 200)
                        .onChange(of: cameraManager.zoomLevel) { oldValue, newValue in
                            cameraManager.setZoom(newValue)
                        }

                    HStack {
                        Button("1x") { cameraManager.setZoom(1.0) }
                        Button("1.5x") { cameraManager.setZoom(1.5) }
                        Button("2x") { cameraManager.setZoom(2.0) }
                    }
                    .buttonStyle(.bordered)

                    // FOV Control
                    Text("Field of View")
                        .font(.subheadline)
                        .padding(.top, 5)

                    HStack {
                        Button("Wide 86") { cameraManager.setFOV(0) }
                            .tint(.green)
                        Button("Med 78") { cameraManager.setFOV(1) }
                        Button("Narrow 65") { cameraManager.setFOV(2) }
                    }
                    .buttonStyle(.bordered)

                    Divider()

                    // Exercise Tracking
                    Text("Exercise Tracking")
                        .font(.headline)

                    Picker("Exercise", selection: Binding(
                        get: { poseDetector.currentExercise },
                        set: { poseDetector.setExercise($0) }
                    )) {
                        ForEach(PoseDetector.ExerciseType.allCases, id: \.self) { exercise in
                            Text(exercise.rawValue).tag(exercise)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)

                    // Calibration section (for Sit-to-Stand)
                    if poseDetector.currentExercise == .sitToStand {
                        VStack(spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(poseDetector.isCalibrated ? Color.green : Color.orange)
                                    .frame(width: 10, height: 10)
                                Text(poseDetector.isCalibrated ? "Calibrated" : "Not Calibrated")
                                    .font(.caption)
                                    .foregroundColor(poseDetector.isCalibrated ? .green : .orange)
                            }

                            if poseDetector.calibrationState != .notCalibrated &&
                               poseDetector.calibrationState != .calibrated {
                                Text(poseDetector.calibrationMessage)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.center)

                                Button("Cancel") {
                                    poseDetector.cancelCalibration()
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            } else {
                                Button(poseDetector.isCalibrated ? "Re-Calibrate" : "Calibrate") {
                                    poseDetector.startCalibration()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                            }

                            if poseDetector.isCalibrated {
                                Text("Sit: \(String(format: "%.2f", poseDetector.sittingHipY)) | Stand: \(String(format: "%.2f", poseDetector.standingHipY))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Button("Clear Calibration") {
                                    poseDetector.clearCalibration()
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                                .tint(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    Text("\(poseDetector.exerciseCount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)

                    Text("reps completed")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Show last rep score
                    if poseDetector.currentExercise == .sitToStand && poseDetector.lastRepScore > 0 {
                        HStack(spacing: 4) {
                            Text("Last rep:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(poseDetector.lastRepScore)%")
                                .font(.headline)
                                .foregroundColor(scoreColor(poseDetector.lastRepScore))
                        }
                    }

                    // Show exercise state for sit-to-stand
                    if poseDetector.currentExercise == .sitToStand && poseDetector.isCalibrated {
                        HStack {
                            Circle()
                                .fill(stateColor(for: poseDetector.exerciseState))
                                .frame(width: 12, height: 12)
                            Text(poseDetector.exerciseState.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(stateColor(for: poseDetector.exerciseState))
                        }
                        .padding(.vertical, 4)
                    }

                    HStack(spacing: 10) {
                        Button("Reset Count") {
                            poseDetector.resetCount()
                            photoManager.startSession()
                        }
                        .buttonStyle(.bordered)

                        Button("Gallery (\(photoManager.photos.count))") {
                            showGallery = true
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                    }

                    Spacer()

                    // Refresh button
                    Button("Scan for Cameras") {
                        cameraManager.scanForDevices()
                        cameraCapture.loadAvailableCameras()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(30)
            }
            .frame(minWidth: 300)
        }
        .frame(minWidth: 800, minHeight: 500)
        .onAppear {
            cameraManager.initialize()
            setupPhotoCaptureCallback()
            photoManager.startSession()
        }
        .sheet(isPresented: $showGallery) {
            SessionGalleryView(photoManager: photoManager)
        }
    }

    private func setupPhotoCaptureCallback() {
        poseDetector.onCapturePhoto = { [weak cameraCapture, weak photoManager] repNumber, position in
            guard let cameraCapture = cameraCapture,
                  let photoManager = photoManager,
                  let image = cameraCapture.capturePhoto() else {
                return
            }

            let pos: ExercisePhoto.Position = position == "sitting" ? .sitting : .standing
            photoManager.capturePhoto(image: image, repNumber: repNumber, position: pos)
        }

        poseDetector.onRepCompleted = { [weak photoManager] repNumber, score in
            photoManager?.updateScore(forRep: repNumber, score: score)
        }
    }

    private func stateColor(for state: PoseDetector.ExerciseState) -> Color {
        switch state {
        case .standing:
            return .green
        case .goingDown:
            return .orange
        case .holdingSit:
            return .yellow
        case .sitting:
            return .blue
        case .goingUp:
            return .purple
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70..<90: return .blue
        case 50..<70: return .orange
        default: return .red
        }
    }

    private func savePhoto(_ image: CGImage) {
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "photo_\(Date().timeIntervalSince1970).png"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                if let tiffData = nsImage.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmap.representation(using: .png, properties: [:]) {
                    try? pngData.write(to: url)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(OBSBOTManager())
}
