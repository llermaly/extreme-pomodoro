import AVFoundation
import SwiftUI
import CoreImage

/// Manages camera video capture using AVFoundation
class CameraCapture: NSObject, ObservableObject {
    @Published var currentFrame: CGImage?
    @Published var isCapturing: Bool = false
    @Published var availableCameras: [AVCaptureDevice] = []
    @Published var selectedCamera: AVCaptureDevice?

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let context = CIContext()

    /// Pose detector for body tracking
    var poseDetector: PoseDetector?
    private var frameCount = 0
    private let detectEveryNFrames = 3 // Process every 3rd frame for performance

    override init() {
        super.init()
        checkPermissions()
    }

    /// Check camera permissions
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            loadAvailableCameras()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.loadAvailableCameras()
                    }
                }
            }
        default:
            break
        }
    }

    /// Load all available cameras
    func loadAvailableCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external, .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )

        DispatchQueue.main.async {
            self.availableCameras = discoverySession.devices

            // Try to find the OBSBOT camera
            if let obsbot = self.availableCameras.first(where: { $0.localizedName.contains("OBSBOT") }) {
                self.selectedCamera = obsbot
            } else if let first = self.availableCameras.first {
                self.selectedCamera = first
            }
        }
    }

    /// Start capturing video
    func startCapture() {
        guard let camera = selectedCamera else {
            print("No camera selected")
            return
        }

        sessionQueue.async { [weak self] in
            self?.setupCaptureSession(with: camera)
        }
    }

    /// Stop capturing video
    func stopCapture() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self?.isCapturing = false
            }
        }
    }

    /// Select a different camera
    func selectCamera(_ camera: AVCaptureDevice) {
        let wasCapturing = isCapturing
        if wasCapturing {
            stopCapture()
        }

        selectedCamera = camera

        if wasCapturing {
            startCapture()
        }
    }

    private func setupCaptureSession(with camera: AVCaptureDevice) {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        do {
            let input = try AVCaptureDeviceInput(device: camera)

            if session.canAddInput(input) {
                session.addInput(input)
            }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            self.captureSession = session
            self.videoOutput = output

            session.startRunning()

            DispatchQueue.main.async {
                self.isCapturing = true
            }

        } catch {
            print("Failed to setup capture session: \(error)")
        }
    }

    /// Capture a single photo from the current frame
    func capturePhoto() -> CGImage? {
        return currentFrame
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            DispatchQueue.main.async {
                self.currentFrame = cgImage
            }

            // Run pose detection every N frames
            frameCount += 1
            if frameCount >= detectEveryNFrames {
                frameCount = 0
                poseDetector?.detectPose(in: cgImage)
            }
        }
    }
}

// MARK: - SwiftUI Camera Preview View
struct CameraPreviewView: View {
    @ObservedObject var cameraCapture: CameraCapture

    var body: some View {
        GeometryReader { geometry in
            if let frame = cameraCapture.currentFrame {
                Image(decorative: frame, scale: 1.0, orientation: .up)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))

                    if cameraCapture.isCapturing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        VStack {
                            Image(systemName: "video.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Camera not started")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}
