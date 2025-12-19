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
    private let gestureHoldDuration: TimeInterval = 1.5
    private let gestureReleaseDuration: TimeInterval = 0.5

    private var sittingStartTime: Date? = nil
    private let sittingHoldDuration: TimeInterval = 0.3
    private let hysteresisPercent: CGFloat = 0.85

    private var sittingPhotoCaptured: Bool = false

    var onRepCompleted: ((Int) -> Void)?
    var ttsService: TTSService = NativeTTSService()
    var onCapturePhoto: ((Int, String) -> Void)?

    enum ExerciseType: String, CaseIterable {
        case sitToStand = "Sit-to-Stand"
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
                self.isPersonDetected = false
                self.currentPose = nil
                self.poseDescription = "No person detected"
            }
        } catch {
            print("Pose detection error: \(error)")
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

    // MARK: - 2D Pose Detection (New Swift API)

    private func detect2DPose(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        let request = DetectHumanBodyPoseRequest()
        let results = try await request.perform(on: pixelBuffer)

        guard let observation = results.first else { return nil }
        return extractPose2D(from: observation)
    }

    private func extractPose2D(from observation: HumanBodyPoseObservation) -> DetectedPose {
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
                    if let unifiedName = mapJointName2D(jointName) {
                        pose.joints[unifiedName] = point
                    }
                }
            }
        }

        return pose
    }

    private func mapJointName2D(_ jointName: HumanBodyPoseObservation.JointName) -> UnifiedJointName? {
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

    // MARK: - 3D Pose Detection (New Swift API)

    private func detect3DPose(in pixelBuffer: CVPixelBuffer) async throws -> DetectedPose? {
        let request = DetectHumanBodyPose3DRequest()
        let results = try await request.perform(on: pixelBuffer)

        guard let observation = results.first else { return nil }
        return try extractPose3D(from: observation)
    }

    private func extractPose3D(from observation: HumanBodyPose3DObservation) throws -> DetectedPose {
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
                if let unifiedName = mapJointName3D(jointName) {
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

    private func mapJointName3D(_ jointName: HumanBodyPose3DObservation.JointName) -> UnifiedJointName? {
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

    private func speak(_ text: String) {
        ttsService.speak(text)
    }

    private func playBeep() {
        NSSound.beep()
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
        calibrationMessage = "Put hands on hips to start"
        resetGestureState()
        gestureResetRequired = false
        speak("Put your hands on your hips to begin calibration")
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

        let handsCurrentlyOnHips = pose.handsOnHips

        if gestureResetRequired {
            if !handsCurrentlyOnHips {
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

        if handsCurrentlyOnHips {
            if armsRaisedStartTime == nil {
                armsRaisedStartTime = Date()
            } else if let startTime = armsRaisedStartTime,
                      Date().timeIntervalSince(startTime) >= gestureHoldDuration,
                      !armsWereRaised {
                armsWereRaised = true
                handleCalibrationGesture(pose)
            }
        } else {
            armsRaisedStartTime = nil
            armsWereRaised = false
        }
    }

    private func handleCalibrationGesture(_ pose: DetectedPose) {
        guard let hipY = pose.hipY else { return }

        switch calibrationState {
        case .waitingForReady:
            playBeep()
            calibrationState = .waitingForSit
            calibrationMessage = "Release hands, sit down, then hands on hips"
            speak("Good! Release your hands, sit down on your poof, then put hands on hips again")
            resetGestureState()
            gestureResetRequired = true

        case .waitingForSit:
            playBeep()
            sittingHipY = hipY
            calibrationState = .waitingForStand
            calibrationMessage = "Sitting saved! Release, stand up, hands on hips"
            speak("Sitting position saved. Release your hands, stand up, then put hands on hips again")
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
        let sittingThreshold = sittingHipY + (range * (1 - hysteresisPercent))

        return hipY <= sittingThreshold
    }

    func isInStandingZone(_ pose: DetectedPose) -> Bool {
        guard isCalibrated, let hipY = pose.hipY else { return false }

        let range = abs(standingHipY - sittingHipY)
        let standingThreshold = standingHipY - (range * (1 - hysteresisPercent))

        return hipY >= standingThreshold
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
        case .jumpingJacks, .squats, .armRaises:
            trackSimpleExercise(pose)
        }
    }

    private func trackSitToStand(_ pose: DetectedPose) {
        guard isCalibrated else { return }

        let inSittingZone = isInSittingZone(pose)
        let inStandingZone = isInStandingZone(pose)

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

// MARK: - NormalizedPoint Extension

extension NormalizedPoint {
    func verticallyFlipped() -> NormalizedPoint {
        NormalizedPoint(x: self.x, y: 1 - self.y)
    }

    var cgPoint: CGPoint {
        CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}
