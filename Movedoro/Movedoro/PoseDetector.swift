import Vision
import CoreImage
import SwiftUI
import AppKit
import AVFoundation
import simd

// MARK: - Pose Detection Mode

enum PoseDetectionMode: String, CaseIterable {
    case mode2D = "2D"
    case mode3D = "3D"
}

// MARK: - Unified Joint Name (maps both 2D and 3D joints)

enum UnifiedJointName: String, CaseIterable, Hashable {
    // Head
    case nose, leftEye, rightEye, leftEar, rightEar
    case topHead, centerHead
    // Torso
    case neck, leftShoulder, rightShoulder, centerShoulder
    case spine, root
    case leftHip, rightHip
    // Arms
    case leftElbow, rightElbow
    case leftWrist, rightWrist
    // Legs
    case leftKnee, rightKnee
    case leftAnkle, rightAnkle
}

// MARK: - Detected Pose (unified for 2D and 3D)

struct DetectedPose {
    var joints: [UnifiedJointName: CGPoint] = [:]  // 2D screen positions (normalized 0-1)
    var joints3D: [UnifiedJointName: simd_float3] = [:]  // 3D positions in meters (3D mode only)
    var confidence: Float = 0.0
    var is3D: Bool = false

    // 3D-specific properties
    var bodyHeight: Float?  // Estimated height in meters
    var cameraDistance: Float?  // Distance from camera in meters

    /// Check if person is in a standing position
    var isStanding: Bool {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle] else {
            return false
        }

        let avgHipY = (leftHip.y + rightHip.y) / 2
        let avgAnkleY = (leftAnkle.y + rightAnkle.y) / 2

        return avgHipY < avgAnkleY
    }

    /// Check if arms are raised
    var armsRaised: Bool {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder] else {
            return false
        }

        return leftWrist.y < leftShoulder.y && rightWrist.y < rightShoulder.y
    }

    /// Check if hands are on hips
    var handsOnHips: Bool {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder] else {
            return false
        }

        let hipY = (leftHip.y + rightHip.y) / 2
        let shoulderY = (leftShoulder.y + rightShoulder.y) / 2
        let torsoHeight = abs(shoulderY - hipY)
        let tolerance = torsoHeight * 0.6

        let leftWristNearHip = abs(leftWrist.y - leftHip.y) < tolerance
        let rightWristNearHip = abs(rightWrist.y - rightHip.y) < tolerance

        let shoulderWidth = abs(leftShoulder.x - rightShoulder.x)
        let wristSpread = abs(leftWrist.x - rightWrist.x)
        let wristsSpreadApart = wristSpread > shoulderWidth * 0.4

        return leftWristNearHip && rightWristNearHip && wristsSpreadApart
    }

    /// Check if hands are close together (e.g., clasped or prayer position)
    var handsCloseTogether: Bool {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist] else {
            return false
        }

        // Try to get a reference width - prefer shoulders, fallback to hips
        let referenceWidth: CGFloat
        let bodyCenter: CGFloat

        if let leftShoulder = joints[.leftShoulder],
           let rightShoulder = joints[.rightShoulder] {
            referenceWidth = abs(leftShoulder.x - rightShoulder.x)
            bodyCenter = (leftShoulder.x + rightShoulder.x) / 2
        } else if let leftHip = joints[.leftHip],
                  let rightHip = joints[.rightHip] {
            // Fallback: use hip width (slightly narrower than shoulders typically)
            referenceWidth = abs(leftHip.x - rightHip.x) * 1.2
            bodyCenter = (leftHip.x + rightHip.x) / 2
        } else {
            // Last resort: use absolute distance threshold (normalized coordinates 0-1)
            let wristDistance = abs(leftWrist.x - rightWrist.x)
            let verticalDistance = abs(leftWrist.y - rightWrist.y)
            // Wrists within ~15% of screen width and similar height
            return wristDistance < 0.15 && verticalDistance < 0.1
        }

        // Wrists should be close horizontally (within 50% of reference width - more lenient)
        let wristHorizontalDistance = abs(leftWrist.x - rightWrist.x)
        let wristsCloseHorizontally = wristHorizontalDistance < referenceWidth * 0.5

        // Wrists should be at similar height (within 40% of reference width - more lenient)
        let wristVerticalDistance = abs(leftWrist.y - rightWrist.y)
        let wristsCloseVertically = wristVerticalDistance < referenceWidth * 0.4

        // Wrists should be in front of body (between shoulders horizontally)
        let wristsCenter = (leftWrist.x + rightWrist.x) / 2
        let wristsCentered = abs(wristsCenter - bodyCenter) < referenceWidth * 0.5

        return wristsCloseHorizontally && wristsCloseVertically && wristsCentered
    }

    /// Check if in squat position
    var isSquatting: Bool {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftKnee = joints[.leftKnee],
              let rightKnee = joints[.rightKnee] else {
            return false
        }

        let avgHipY = (leftHip.y + rightHip.y) / 2
        let avgKneeY = (leftKnee.y + rightKnee.y) / 2

        return abs(avgHipY - avgKneeY) < 0.15
    }

    /// Get average hip Y position (for calibration)
    var hipY: CGFloat? {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip] else {
            return nil
        }
        return (leftHip.y + rightHip.y) / 2
    }
}

// MARK: - Pose Detector

@MainActor
class PoseDetector: ObservableObject {
    @Published var currentPose: DetectedPose?
    @Published var isPersonDetected: Bool = false
    @Published var poseDescription: String = "No pose detected"

    // Detection mode
    @Published var detectionMode: PoseDetectionMode = .mode2D {
        didSet {
            UserDefaults.standard.set(detectionMode.rawValue, forKey: "poseDetectionMode")
        }
    }

    // 3D-specific info
    @Published var bodyHeight: String = "--"
    @Published var cameraDistance: String = "--"

    // Exercise tracking
    @Published var exerciseCount: Int = 0
    @Published var currentExercise: ExerciseType = .sitToStand

    // Calibration state
    @Published var calibrationState: CalibrationState = .notCalibrated
    @Published var calibrationMessage: String = ""
    @Published var isCalibrated: Bool = false

    // Calibrated thresholds
    @Published var sittingHipY: CGFloat = 0.0 {
        didSet { saveCalibration() }
    }
    @Published var standingHipY: CGFloat = 0.0 {
        didSet { saveCalibration() }
    }

    // UserDefaults keys
    private let kSittingHipY = "calibration.sittingHipY"
    private let kStandingHipY = "calibration.standingHipY"
    private let kIsCalibrated = "calibration.isCalibrated"

    // Exercise state machine
    @Published var exerciseState: ExerciseState = .standing

    enum ExerciseState: String {
        case standing = "Standing"
        case goingDown = "Going Down"
        case holdingSit = "Hold Sit..."
        case sitting = "Sitting"
        case goingUp = "Going Up"
    }

    private var lastPoseState: Bool = false
    private var armsRaisedStartTime: Date? = nil
    private var armsWereRaised: Bool = false
    private var gestureResetRequired: Bool = false
    private var gestureReleaseStartTime: Date? = nil
    private let gestureHoldDuration: TimeInterval = 2.0
    private let gestureReleaseDuration: TimeInterval = 0.5

    // Gesture hold progress for UI (0.0 to 1.0)
    @Published var gestureHoldProgress: Double = 0.0

    private var sittingStartTime: Date? = nil
    private let sittingHoldDuration: TimeInterval = 0.3
    private let hysteresisPercent: CGFloat = 0.85

    private var sittingPhotoCaptured: Bool = false

    var onRepCompleted: ((Int) -> Void)?
    var ttsService: TTSService = NativeTTSService()
    var onCapturePhoto: ((Int, String) -> Void)?

    enum ExerciseType: String, CaseIterable {
        case sitToStand = "Sit-to-Stand"
        case standingDesk = "Standing Desk"
        case jumpingJacks = "Jumping Jacks"
        case squats = "Squats"
        case armRaises = "Arm Raises"
    }

    enum CalibrationState: Equatable {
        case notCalibrated
        case waitingForReady
        case waitingForSit
        case waitingForStand
        case calibrated
    }

    // MARK: - Initialization

    init() {
        loadCalibration()
        // Load saved detection mode
        if let savedMode = UserDefaults.standard.string(forKey: "poseDetectionMode"),
           let mode = PoseDetectionMode(rawValue: savedMode) {
            detectionMode = mode
        }
    }

    // MARK: - Pose Detection (New Swift Vision API)

    /// Process a frame using the new Swift Vision API (async)
    func detectPose(in pixelBuffer: CVPixelBuffer) async {
        do {
            let pose: DetectedPose?

            switch detectionMode {
            case .mode2D:
                pose = try await detect2DPose(in: pixelBuffer)
            case .mode3D:
                pose = try await detect3DPose(in: pixelBuffer)
            }

            if let pose = pose {
                self.currentPose = pose

                // Play sound when person first detected
                if !self.wasPersonDetected {
                    self.playPersonDetectedSound()
                }
                self.wasPersonDetected = true
                self.isPersonDetected = true

                self.updatePoseDescription(pose)
                self.processCalibration(pose)
                self.trackExercise(pose)

                // Update 3D info display
                if pose.is3D {
                    if let height = pose.bodyHeight {
                        self.bodyHeight = String(format: "%.2f m", height)
                    }
                    if let distance = pose.cameraDistance {
                        self.cameraDistance = String(format: "%.2f m", distance)
                    }
                } else {
                    self.bodyHeight = "--"
                    self.cameraDistance = "--"
                }
            } else {
                self.wasPersonDetected = false
                self.isPersonDetected = false
                self.currentPose = nil
                self.poseDescription = "No person detected"
            }
        } catch {
            print("Pose detection error: \(error)")
            self.wasPersonDetected = false
            self.isPersonDetected = false
            self.currentPose = nil
            self.poseDescription = "Detection error"
        }
    }

    /// Backward compatible method for CGImage input
    func detectPose(in cgImage: CGImage) {
        Task {
            // Convert CGImage to CVPixelBuffer
            guard let pixelBuffer = cgImage.toPixelBuffer() else {
                await MainActor.run {
                    self.isPersonDetected = false
                    self.currentPose = nil
                    self.poseDescription = "Image conversion failed"
                }
                return
            }
            await detectPose(in: pixelBuffer)
        }
    }

    // MARK: - 2D Pose Detection

    private func detect2DPose(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        if #available(macOS 26.0, *) {
            return try await detect2DPoseModern(in: pixelBuffer)
        } else {
            return try await detect2DPoseLegacy(in: pixelBuffer)
        }
    }

    // Modern API (macOS 26+)
    @available(macOS 26.0, *)
    private func detect2DPoseModern(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        let request = DetectHumanBodyPoseRequest()
        let results = try await request.perform(on: pixelBuffer)

        guard let observation = results.first else { return nil }
        return extractPose2DModern(from: observation)
    }

    @available(macOS 26.0, *)
    private func extractPose2DModern(from observation: HumanBodyPoseObservation) -> DetectedPose {
        var pose = DetectedPose()
        pose.confidence = observation.confidence
        pose.is3D = false

        // Map joint groups to unified names
        let jointGroups: [HumanBodyPoseObservation.JointsGroupName] = [.face, .torso, .leftArm, .rightArm, .leftLeg, .rightLeg]

        for groupName in jointGroups {
            let jointsInGroup = observation.allJoints(in: groupName)
            for (jointName, joint) in jointsInGroup {
                if joint.confidence > 0.3 {
                    let point = joint.location.verticallyFlipped().cgPoint
                    if let unifiedName = mapJointName2DModern(jointName) {
                        pose.joints[unifiedName] = point
                    }
                }
            }
        }

        return pose
    }

    @available(macOS 26.0, *)
    private func mapJointName2DModern(_ jointName: HumanBodyPoseObservation.JointName) -> UnifiedJointName? {
        switch jointName {
        case .nose: return .nose
        case .leftEye: return .leftEye
        case .rightEye: return .rightEye
        case .leftEar: return .leftEar
        case .rightEar: return .rightEar
        case .leftShoulder: return .leftShoulder
        case .rightShoulder: return .rightShoulder
        case .leftElbow: return .leftElbow
        case .rightElbow: return .rightElbow
        case .leftWrist: return .leftWrist
        case .rightWrist: return .rightWrist
        case .leftHip: return .leftHip
        case .rightHip: return .rightHip
        case .leftKnee: return .leftKnee
        case .rightKnee: return .rightKnee
        case .leftAnkle: return .leftAnkle
        case .rightAnkle: return .rightAnkle
        case .neck: return .neck
        case .root: return .root
        default: return nil
        }
    }

    // Legacy API (macOS 14-25)
    private func detect2DPoseLegacy(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNHumanBodyPoseObservation],
                      let observation = observations.first else {
                    continuation.resume(returning: nil)
                    return
                }

                let pose = self.extractPose2DLegacy(from: observation)
                continuation.resume(returning: pose)
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func extractPose2DLegacy(from observation: VNHumanBodyPoseObservation) -> DetectedPose {
        var pose = DetectedPose()
        pose.confidence = Float(observation.confidence)
        pose.is3D = false

        // Get all recognized points
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            return pose
        }

        for (jointName, point) in recognizedPoints {
            if point.confidence > 0.3 {
                let cgPoint = CGPoint(x: point.location.x, y: 1 - point.location.y) // Flip Y
                if let unifiedName = mapJointName2DLegacy(jointName) {
                    pose.joints[unifiedName] = cgPoint
                }
            }
        }

        return pose
    }

    private func mapJointName2DLegacy(_ jointName: VNHumanBodyPoseObservation.JointName) -> UnifiedJointName? {
        switch jointName {
        case .nose: return .nose
        case .leftEye: return .leftEye
        case .rightEye: return .rightEye
        case .leftEar: return .leftEar
        case .rightEar: return .rightEar
        case .leftShoulder: return .leftShoulder
        case .rightShoulder: return .rightShoulder
        case .leftElbow: return .leftElbow
        case .rightElbow: return .rightElbow
        case .leftWrist: return .leftWrist
        case .rightWrist: return .rightWrist
        case .leftHip: return .leftHip
        case .rightHip: return .rightHip
        case .leftKnee: return .leftKnee
        case .rightKnee: return .rightKnee
        case .leftAnkle: return .leftAnkle
        case .rightAnkle: return .rightAnkle
        case .neck: return .neck
        case .root: return .root
        default: return nil
        }
    }

    // MARK: - 3D Pose Detection

    private func detect3DPose(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        // 3D pose detection is only available on macOS 26+
        // Fall back to 2D detection on older systems
        if #available(macOS 26.0, *) {
            return try await detect3DPoseModern(in: pixelBuffer)
        } else {
            // Fall back to 2D detection on older macOS
            return try await detect2DPoseLegacy(in: pixelBuffer)
        }
    }

    @available(macOS 26.0, *)
    private func detect3DPoseModern(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        let request = DetectHumanBodyPose3DRequest()
        let results = try await request.perform(on: pixelBuffer)

        guard let observation = results.first else { return nil }
        return try extractPose3DModern(from: observation)
    }

    @available(macOS 26.0, *)
    private func extractPose3DModern(from observation: HumanBodyPose3DObservation) throws -> DetectedPose {
        var pose = DetectedPose()
        pose.confidence = observation.confidence
        pose.is3D = true

        // Get body height (convert from Measurement to Float in meters)
        pose.bodyHeight = Float(observation.bodyHeight.converted(to: .meters).value)

        // Get all joints using joint groups (similar to 2D API)
        let jointGroups: [HumanBodyPose3DObservation.JointsGroupName] = [.head, .torso, .leftArm, .rightArm, .leftLeg, .rightLeg]

        for groupName in jointGroups {
            let jointsInGroup = observation.allJoints(in: groupName)
            for (jointName, joint) in jointsInGroup {
                if let unifiedName = mapJointName3DModern(jointName) {
                    // Get 2D projection for screen display
                    if let point2D = try? observation.pointInImage(for: jointName) {
                        pose.joints[unifiedName] = CGPoint(
                            x: CGFloat(point2D.x),
                            y: CGFloat(1 - point2D.y)  // Flip Y for screen coordinates
                        )
                    }

                    // Store 3D position (extract translation from 4x4 matrix)
                    let position = joint.position
                    pose.joints3D[unifiedName] = simd_float3(
                        position.columns.3.x,
                        position.columns.3.y,
                        position.columns.3.z
                    )
                }
            }
        }

        // Calculate camera distance from root joint
        if let rootPos = pose.joints3D[.root] {
            pose.cameraDistance = simd_length(rootPos)
        }

        return pose
    }

    @available(macOS 26.0, *)
    private func mapJointName3DModern(_ jointName: HumanBodyPose3DObservation.JointName) -> UnifiedJointName? {
        switch jointName {
        case .topHead: return .topHead
        case .centerHead: return .centerHead
        case .leftShoulder: return .leftShoulder
        case .rightShoulder: return .rightShoulder
        case .centerShoulder: return .centerShoulder
        case .spine: return .spine
        case .root: return .root
        case .leftHip: return .leftHip
        case .rightHip: return .rightHip
        case .leftElbow: return .leftElbow
        case .rightElbow: return .rightElbow
        case .leftWrist: return .leftWrist
        case .rightWrist: return .rightWrist
        case .leftKnee: return .leftKnee
        case .rightKnee: return .rightKnee
        case .leftAnkle: return .leftAnkle
        case .rightAnkle: return .rightAnkle
        default: return nil
        }
    }

    // MARK: - Calibration Persistence

    private func saveCalibration() {
        guard isCalibrated else { return }
        UserDefaults.standard.set(Double(sittingHipY), forKey: kSittingHipY)
        UserDefaults.standard.set(Double(standingHipY), forKey: kStandingHipY)
        UserDefaults.standard.set(true, forKey: kIsCalibrated)
    }

    private func loadCalibration() {
        let wasCalibrated = UserDefaults.standard.bool(forKey: kIsCalibrated)
        if wasCalibrated {
            let sitting = UserDefaults.standard.double(forKey: kSittingHipY)
            let standing = UserDefaults.standard.double(forKey: kStandingHipY)

            if sitting != 0 && standing != 0 && sitting != standing {
                sittingHipY = CGFloat(sitting)
                standingHipY = CGFloat(standing)
                isCalibrated = true
                calibrationState = .calibrated
                calibrationMessage = "Calibration restored"
            }
        }
    }

    func clearCalibration() {
        UserDefaults.standard.removeObject(forKey: kSittingHipY)
        UserDefaults.standard.removeObject(forKey: kStandingHipY)
        UserDefaults.standard.removeObject(forKey: kIsCalibrated)

        sittingHipY = 0.0
        standingHipY = 0.0
        isCalibrated = false
        calibrationState = .notCalibrated
        calibrationMessage = ""
        resetCount()
    }

    // MARK: - Audio Feedback

    // Track previous states for audio feedback
    private var wasPersonDetected: Bool = false
    private var wasGestureHeld: Bool = false

    private func speak(_ text: String) {
        ttsService.speak(text)
    }

    private func playBeep() {
        NSSound.beep()
    }

    private func playSound(_ name: String) {
        if let sound = NSSound(named: NSSound.Name(name)) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }

    private func playPersonDetectedSound() {
        playSound("Pop")
    }

    private func playGestureStartSound() {
        playSound("Tink")
    }

    var isSpeaking: Bool {
        ttsService.isSpeaking
    }

    func speakAfterCurrent(_ text: String, checkInterval: TimeInterval = 0.2) {
        ttsService.speakAfterCurrent(text, checkInterval: checkInterval)
    }

    // MARK: - Calibration

    func startCalibration() {
        calibrationState = .waitingForReady
        calibrationMessage = "Put hands together for 2 seconds"
        resetGestureState()
        gestureResetRequired = false
        speak("Put your hands together and hold for 2 seconds")
    }

    func cancelCalibration() {
        calibrationState = isCalibrated ? .calibrated : .notCalibrated
        calibrationMessage = ""
        resetGestureState()
        gestureResetRequired = false
    }

    private func processCalibration(_ pose: DetectedPose) {
        guard calibrationState != .notCalibrated && calibrationState != .calibrated else {
            return
        }

        let gestureDetected = pose.handsCloseTogether

        if gestureResetRequired {
            if !gestureDetected {
                if gestureReleaseStartTime == nil {
                    gestureReleaseStartTime = Date()
                } else if let releaseStart = gestureReleaseStartTime,
                          Date().timeIntervalSince(releaseStart) >= gestureReleaseDuration {
                    gestureResetRequired = false
                    gestureReleaseStartTime = nil
                    armsRaisedStartTime = nil
                    armsWereRaised = false
                }
            } else {
                gestureReleaseStartTime = nil
            }
            return
        }

        if gestureDetected {
            if armsRaisedStartTime == nil {
                armsRaisedStartTime = Date()
                // Play sound when hands-together gesture starts
                playGestureStartSound()
            }

            if let startTime = armsRaisedStartTime {
                let elapsed = Date().timeIntervalSince(startTime)
                gestureHoldProgress = min(1.0, elapsed / gestureHoldDuration)

                if elapsed >= gestureHoldDuration && !armsWereRaised {
                    armsWereRaised = true
                    gestureHoldProgress = 0.0
                    handleCalibrationGesture(pose)
                }
            }
        } else {
            armsRaisedStartTime = nil
            armsWereRaised = false
            gestureHoldProgress = 0.0
        }
    }

    /// Returns true if the calibration gesture is currently being held
    var isCalibrationGestureHeld: Bool {
        armsRaisedStartTime != nil && !gestureResetRequired
    }

    private func handleCalibrationGesture(_ pose: DetectedPose) {
        guard let hipY = pose.hipY else { return }

        switch calibrationState {
        case .waitingForReady:
            playBeep()
            calibrationState = .waitingForSit
            calibrationMessage = "Sit down, then hands together for 2 seconds"
            speak("Good! Sit down, then hold hands together for 2 seconds")
            resetGestureState()
            gestureResetRequired = true

        case .waitingForSit:
            playBeep()
            sittingHipY = hipY
            calibrationState = .waitingForStand
            calibrationMessage = "Stand up, then hands together for 2 seconds"
            speak("Sitting saved! Stand up, then hold hands together for 2 seconds")
            resetGestureState()
            gestureResetRequired = true

        case .waitingForStand:
            playBeep()
            standingHipY = hipY
            calibrationState = .calibrated
            isCalibrated = true
            saveCalibration()
            calibrationMessage = "Calibration complete!"
            speak("Calibration complete! You can now start your exercise")
            resetGestureState()
            gestureResetRequired = false

        default:
            break
        }
    }

    private func resetGestureState() {
        armsRaisedStartTime = nil
        armsWereRaised = false
        gestureReleaseStartTime = nil
    }

    func isInSittingZone(_ pose: DetectedPose) -> Bool {
        guard isCalibrated, let hipY = pose.hipY else { return false }

        let range = abs(standingHipY - sittingHipY)
        // Sitting = higher Y value (lower in frame), threshold moves toward standing
        let sittingThreshold = sittingHipY - (range * (1 - hysteresisPercent))

        return hipY >= sittingThreshold
    }

    func isInStandingZone(_ pose: DetectedPose) -> Bool {
        guard isCalibrated, let hipY = pose.hipY else { return false }

        let range = abs(standingHipY - sittingHipY)
        // Standing = lower Y value (higher in frame), threshold moves toward sitting
        let standingThreshold = standingHipY + (range * (1 - hysteresisPercent))

        return hipY <= standingThreshold
    }

    func getPositionPercent(_ pose: DetectedPose) -> CGFloat? {
        guard isCalibrated, let hipY = pose.hipY else { return nil }

        let range = standingHipY - sittingHipY
        guard range != 0 else { return nil }

        let percent = (hipY - sittingHipY) / range * 100
        return max(0, min(100, percent))
    }

    private func updatePoseDescription(_ pose: DetectedPose) {
        var descriptions: [String] = []

        if pose.is3D {
            descriptions.append("3D")
        }
        if pose.isStanding {
            descriptions.append("Standing")
        }
        if pose.handsOnHips {
            descriptions.append("Hands on Hips")
        }
        if pose.handsCloseTogether {
            descriptions.append("Hands Together")
        }
        if pose.armsRaised {
            descriptions.append("Arms Up")
        }
        if pose.isSquatting {
            descriptions.append("Squatting")
        }

        poseDescription = descriptions.isEmpty ? "Person detected" : descriptions.joined(separator: ", ")
    }

    private func trackExercise(_ pose: DetectedPose) {
        guard calibrationState == .notCalibrated || calibrationState == .calibrated else {
            return
        }

        switch currentExercise {
        case .sitToStand:
            trackSitToStand(pose)
        case .standingDesk:
            trackStandingDesk(pose)
        case .jumpingJacks, .squats, .armRaises:
            trackSimpleExercise(pose)
        }
    }

    // Audio feedback for exercise
    var audioFeedbackEnabled: Bool = true
    private var hasAnnouncedReady: Bool = false

    private func trackSitToStand(_ pose: DetectedPose) {
        guard isCalibrated else { return }
        guard pose.hipY != nil else { return }

        let inSittingZone = isInSittingZone(pose)
        let inStandingZone = isInStandingZone(pose)
        let previousState = exerciseState

        // Announce "ready" once when first in standing position
        if inStandingZone && !hasAnnouncedReady && exerciseState == .standing {
            hasAnnouncedReady = true
            speak("ready")
        }

        switch exerciseState {
        case .standing:
            if !inStandingZone {
                exerciseState = .goingDown
                sittingStartTime = nil
                sittingPhotoCaptured = false
            }

        case .goingDown:
            if inSittingZone {
                exerciseState = .holdingSit
                sittingStartTime = Date()
            } else if inStandingZone {
                exerciseState = .standing
                sittingStartTime = nil
            }

        case .holdingSit:
            if inSittingZone {
                if let startTime = sittingStartTime,
                   Date().timeIntervalSince(startTime) >= sittingHoldDuration {
                    exerciseState = .sitting
                    playBeep()
                    if !sittingPhotoCaptured {
                        onCapturePhoto?(exerciseCount + 1, "sitting")
                        sittingPhotoCaptured = true
                    }
                }
            } else {
                exerciseState = .goingDown
                sittingStartTime = nil
            }

        case .sitting:
            if !inSittingZone {
                exerciseState = .goingUp
            }

        case .goingUp:
            if inStandingZone {
                exerciseCount += 1

                speak("\(exerciseCount)")

                onCapturePhoto?(exerciseCount, "standing")
                onRepCompleted?(exerciseCount)

                exerciseState = .standing
                sittingStartTime = nil
            } else if inSittingZone {
                exerciseState = .holdingSit
                sittingStartTime = Date()
            }
        }

        // Audio feedback for state changes
        if audioFeedbackEnabled && exerciseState != previousState {
            announceStateChange(from: previousState, to: exerciseState)
        }
    }

    private func announceStateChange(from oldState: ExerciseState, to newState: ExerciseState) {
        switch newState {
        case .standing:
            // Rep count is already spoken, no need for extra audio
            break
        case .goingDown:
            speak("down")
        case .holdingSit:
            speak("hold")
        case .sitting:
            // Beep already plays here
            break
        case .goingUp:
            // Skip "up" - the rep count will be spoken right after
            break
        }
    }

    // Standing desk tracking - continuous posture monitoring
    @Published var standingDeskState: StandingDeskState = .unknown
    private var lastStandingDeskStateChange: Date = Date()
    @Published var currentPositionDuration: TimeInterval = 0

    enum StandingDeskState: String {
        case unknown = "Detecting..."
        case sitting = "Sitting"
        case standing = "Standing"
    }

    private func trackStandingDesk(_ pose: DetectedPose) {
        guard isCalibrated else {
            standingDeskState = .unknown
            return
        }

        let inSittingZone = isInSittingZone(pose)
        let inStandingZone = isInStandingZone(pose)
        let previousState = standingDeskState

        if inStandingZone {
            standingDeskState = .standing
        } else if inSittingZone {
            standingDeskState = .sitting
        }

        // Track duration in current position
        if standingDeskState != previousState && previousState != .unknown {
            lastStandingDeskStateChange = Date()
            currentPositionDuration = 0
        } else {
            currentPositionDuration = Date().timeIntervalSince(lastStandingDeskStateChange)
        }
    }

    private func trackSimpleExercise(_ pose: DetectedPose) {
        var currentState: Bool

        switch currentExercise {
        case .jumpingJacks:
            currentState = pose.armsRaised
        case .squats:
            currentState = pose.isSquatting
        case .armRaises:
            currentState = pose.armsRaised
        default:
            return
        }

        if lastPoseState && !currentState {
            exerciseCount += 1
            speak("\(exerciseCount)")
        }

        lastPoseState = currentState
    }

    func resetCount() {
        exerciseCount = 0
        lastPoseState = false
        exerciseState = .standing
        sittingStartTime = nil
        sittingPhotoCaptured = false
        hasAnnouncedReady = false
    }

    #if DEBUG
    /// Debug method to add a fake rep for testing
    func addFakeRep() {
        exerciseCount += 1
        speak("\(exerciseCount)")
        onRepCompleted?(exerciseCount)
    }
    #endif

    func setExercise(_ exercise: ExerciseType) {
        currentExercise = exercise
        resetCount()
    }

    func getExerciseStateDescription() -> String {
        guard currentExercise == .sitToStand && isCalibrated else {
            return ""
        }
        return exerciseState.rawValue
    }
}

// MARK: - Pose Overlay View

struct PoseOverlayView: View {
    let pose: DetectedPose?
    let imageSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            if let pose = pose {
                Canvas { context, size in
                    let scaleX = size.width
                    let scaleY = size.height

                    // Draw skeleton lines
                    drawSkeleton(context: context, pose: pose, scaleX: scaleX, scaleY: scaleY)

                    // Draw joint points
                    for (jointName, point) in pose.joints {
                        let screenPoint = CGPoint(
                            x: point.x * scaleX,
                            y: point.y * scaleY
                        )

                        // Different colors for 3D mode
                        let color: Color = pose.is3D ? .cyan : .green
                        let size: CGFloat = pose.is3D ? 8 : 10

                        context.fill(
                            Circle().path(in: CGRect(x: screenPoint.x - size/2, y: screenPoint.y - size/2, width: size, height: size)),
                            with: .color(color)
                        )

                        // Draw white border
                        context.stroke(
                            Circle().path(in: CGRect(x: screenPoint.x - size/2, y: screenPoint.y - size/2, width: size, height: size)),
                            with: .color(.white),
                            lineWidth: 1
                        )
                    }
                }
            }
        }
    }

    private func drawSkeleton(context: GraphicsContext, pose: DetectedPose, scaleX: CGFloat, scaleY: CGFloat) {
        // Different connections for 2D vs 3D
        let connections: [(UnifiedJointName, UnifiedJointName)]

        if pose.is3D {
            // 3D skeleton connections
            connections = [
                // Head
                (.topHead, .centerHead),
                (.centerHead, .centerShoulder),
                // Torso
                (.leftShoulder, .centerShoulder),
                (.rightShoulder, .centerShoulder),
                (.centerShoulder, .spine),
                (.spine, .root),
                (.root, .leftHip),
                (.root, .rightHip),
                // Arms
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                (.rightShoulder, .rightElbow),
                (.rightElbow, .rightWrist),
                // Legs
                (.leftHip, .leftKnee),
                (.leftKnee, .leftAnkle),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle)
            ]
        } else {
            // 2D skeleton connections
            connections = [
                // Shoulders
                (.leftShoulder, .rightShoulder),
                // Arms
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                (.rightShoulder, .rightElbow),
                (.rightElbow, .rightWrist),
                // Torso
                (.leftShoulder, .leftHip),
                (.rightShoulder, .rightHip),
                (.leftHip, .rightHip),
                // Legs
                (.leftHip, .leftKnee),
                (.leftKnee, .leftAnkle),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle)
            ]
        }

        let lineColor: Color = pose.is3D ? .cyan : .green
        let lineWidth: CGFloat = pose.is3D ? 3 : 2

        for (start, end) in connections {
            guard let startPoint = pose.joints[start],
                  let endPoint = pose.joints[end] else {
                continue
            }

            let p1 = CGPoint(x: startPoint.x * scaleX, y: startPoint.y * scaleY)
            let p2 = CGPoint(x: endPoint.x * scaleX, y: endPoint.y * scaleY)

            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)

            context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
        }
    }
}

// MARK: - CGImage Extension

extension CGImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = self.width
        let height = self.height

        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return buffer
    }
}

// MARK: - NormalizedPoint Extension (macOS 26+)

@available(macOS 26.0, *)
extension NormalizedPoint {
    func verticallyFlipped() -> NormalizedPoint {
        NormalizedPoint(x: self.x, y: 1 - self.y)
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}
