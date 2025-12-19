import SwiftUI
import AVFoundation

/// Advanced settings for camera and calibration
struct AdvancedSettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @StateObject private var cameraCapture = CameraCapture()
    @StateObject private var poseDetector = PoseDetector()

    @State private var showPoseOverlay = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Advanced Settings")
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

            HStack(spacing: 0) {
                // Left: Camera Preview
                VStack {
                    ZStack {
                        CameraPreviewView(cameraCapture: cameraCapture)
                            .frame(width: 400, height: 300)

                        if showPoseOverlay {
                            PoseOverlayView(pose: poseDetector.currentPose, imageSize: CGSize(width: 400, height: 300))
                                .frame(width: 400, height: 300)
                        }
                    }
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                    // Camera controls
                    HStack {
                        if !cameraCapture.availableCameras.isEmpty {
                            Picker("Camera", selection: Binding(
                                get: { cameraCapture.selectedCamera },
                                set: { if let cam = $0 { cameraCapture.selectCamera(cam) } }
                            )) {
                                ForEach(cameraCapture.availableCameras, id: \.uniqueID) { camera in
                                    Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                                }
                            }
                            .frame(width: 200)
                        }

                        Button(cameraCapture.isCapturing ? "Stop" : "Start") {
                            if cameraCapture.isCapturing {
                                cameraCapture.stopCapture()
                            } else {
                                cameraCapture.poseDetector = poseDetector
                                cameraCapture.startCapture()
                            }
                        }
                        .buttonStyle(.bordered)

                        Toggle("Skeleton", isOn: $showPoseOverlay)
                            .toggleStyle(.button)
                    }
                    .padding(.top, 10)

                    // Pose status
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

                // Right: Controls
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Camera Selection Section
                        GroupBox("Camera") {
                            VStack(alignment: .leading, spacing: 12) {
                                Button("Scan for Cameras") {
                                    cameraCapture.loadAvailableCameras()
                                }
                                .buttonStyle(.bordered)

                                if !cameraCapture.availableCameras.isEmpty {
                                    Text("Available cameras: \(cameraCapture.availableCameras.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Calibration Section
                        GroupBox("Exercise Calibration") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(poseDetector.isCalibrated ? Color.green : Color.orange)
                                        .frame(width: 10, height: 10)
                                    Text(poseDetector.isCalibrated ? "Calibrated" : "Not Calibrated")
                                        .foregroundColor(poseDetector.isCalibrated ? .green : .orange)
                                }

                                if poseDetector.calibrationState != .notCalibrated &&
                                   poseDetector.calibrationState != .calibrated {
                                    Text(poseDetector.calibrationMessage)
                                        .font(.caption)
                                        .foregroundColor(.blue)

                                    Button("Cancel") {
                                        poseDetector.cancelCalibration()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                } else {
                                    Button(poseDetector.isCalibrated ? "Re-Calibrate" : "Calibrate") {
                                        if !cameraCapture.isCapturing {
                                            cameraCapture.poseDetector = poseDetector
                                            cameraCapture.startCapture()
                                        }
                                        poseDetector.startCalibration()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.purple)
                                }

                                if poseDetector.isCalibrated {
                                    Text("Sit Y: \(String(format: "%.3f", poseDetector.sittingHipY))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Stand Y: \(String(format: "%.3f", poseDetector.standingHipY))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Button("Clear Calibration") {
                                        poseDetector.clearCalibration()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    .font(.caption)
                                }
                            }
                        }

                        // Debug Info
                        #if DEBUG
                        GroupBox("Debug Info") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Exercise State: \(poseDetector.exerciseState.rawValue)")
                                    .font(.caption)
                                Text("Rep Count: \(poseDetector.exerciseCount)")
                                    .font(.caption)

                                if let pose = poseDetector.currentPose, let hipY = pose.hipY {
                                    Text("Current Hip Y: \(String(format: "%.3f", hipY))")
                                        .font(.caption)
                                }
                            }
                        }
                        #endif
                    }
                    .padding()
                }
                .frame(width: 350)
            }
        }
        .frame(width: 800, height: 600)
        .onDisappear {
            cameraCapture.stopCapture()
        }
    }
}

#Preview {
    AdvancedSettingsView()
        .environmentObject(AppState())
}
