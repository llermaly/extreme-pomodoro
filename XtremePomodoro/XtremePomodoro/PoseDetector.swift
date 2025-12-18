import Vision
import CoreImage
import SwiftUI
import AppKit
import AVFoundation

/// Detected body pose with joint positions
struct DetectedPose {
    var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    var confidence: Float = 0.0

    /// Check if person is in a standing position
    var isStanding: Bool {
        guard let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftAnkle = joints[.leftAnkle],
              let rightAnkle = joints[.rightAnkle] else {
            return false
        }

        // Hips should be above ankles
        let avgHipY = (leftHip.y + rightHip.y) / 2
        let avgAnkleY = (leftAnkle.y + rightAnkle.y) / 2

        return avgHipY < avgAnkleY // In image coordinates, y increases downward
    }

    /// Check if arms are raised (like in jumping jacks)
    var armsRaised: Bool {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder] else {
            return false
        }

        // Wrists should be above shoulders
        return leftWrist.y < leftShoulder.y && rightWrist.y < rightShoulder.y
    }

    /// Check if hands are on hips (superhero pose)
    var handsOnHips: Bool {
        guard let leftWrist = joints[.leftWrist],
              let rightWrist = joints[.rightWrist],
              let leftHip = joints[.leftHip],
              let rightHip = joints[.rightHip],
              let leftShoulder = joints[.leftShoulder],
              let rightShoulder = joints[.rightShoulder] else {
            return false
        }

        // Wrists should be near hip level (within tolerance)
        let hipY = (leftHip.y + rightHip.y) / 2
        let shoulderY = (leftShoulder.y + rightShoulder.y) / 2
        let torsoHeight = abs(shoulderY - hipY)
        let tolerance = torsoHeight * 0.4 // 40% of torso height tolerance

        let leftWristNearHip = abs(leftWrist.y - leftHip.y) < tolerance
        let rightWristNearHip = abs(rightWrist.y - rightHip.y) < tolerance

        // Wrists should be spread apart (near the sides, not together)
        let shoulderWidth = abs(leftShoulder.x - rightShoulder.x)
        let wristSpread = abs(leftWrist.x - rightWrist.x)
        let wristsSpreadApart = wristSpread > shoulderWidth * 0.5

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

        // Hips should be close to knee level
        let avgHipY = (leftHip.y + rightHip.y) / 2
        let avgKneeY = (leftKnee.y + rightKnee.y) / 2

        return abs(avgHipY - avgKneeY) < 0.15 // Hips near knee level
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

/// Manages pose detection using Vision framework
class PoseDetector: ObservableObject {
    @Published var currentPose: DetectedPose?
    @Published var isPersonDetected: Bool = false
    @Published var poseDescription: String = "No pose detected"

    // Exercise tracking
    @Published var exerciseCount: Int = 0
    @Published var currentExercise: ExerciseType = .sitToStand

    // Calibration state
    @Published var calibrationState: CalibrationState = .notCalibrated
    @Published var calibrationMessage: String = ""
    @Published var isCalibrated: Bool = false

    // Calibrated thresholds (persisted to UserDefaults)
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

    // Exercise state machine for sit-to-stand
    @Published var exerciseState: ExerciseState = .standing

    enum ExerciseState: String {
        case standing = "Standing"
        case goingDown = "Going Down"
        case holdingSit = "Hold Sit..."
        case sitting = "Sitting"
        case goingUp = "Going Up"
    }

    private var lastPoseState: Bool = false // For counting reps (other exercises)
    private var armsRaisedStartTime: Date? = nil
    private var armsWereRaised: Bool = false
    private var gestureResetRequired: Bool = false // Must release gesture before next step
    private var gestureReleaseStartTime: Date? = nil // Track when hands left hips
    private let gestureHoldDuration: TimeInterval = 1.5 // Hold hands on hips for 1.5 seconds
    private let gestureReleaseDuration: TimeInterval = 0.5 // Must keep hands off hips for 0.5s

    // Sit-to-stand tracking
    private var sittingStartTime: Date? = nil
    private let sittingHoldDuration: TimeInterval = 0.3 // Must hold sit for 0.3 seconds
    private let hysteresisPercent: CGFloat = 0.85 // Must reach 85% of calibrated position

    // Score tracking - tracks how close to ideal positions
    private var lowestHipYInRep: CGFloat = 1.0  // Track lowest point during sit (closer to sittingHipY = better)
    private var highestHipYInRep: CGFloat = 0.0 // Track highest point during stand (closer to standingHipY = better)
    @Published var lastRepScore: Int = 0        // Score 0-100 for last rep
    @Published var repScores: [Int] = []        // All rep scores

    // Callback for rep completion with score
    var onRepCompleted: ((Int, Int) -> Void)?   // (repNumber, score)

    // Audio feedback
    private let speechSynthesizer = NSSpeechSynthesizer()

    // Photo capture callback - called when a photo should be taken
    // Parameters: repNumber, position ("sitting" or "standing")
    var onCapturePhoto: ((Int, String) -> Void)?

    enum ExerciseType: String, CaseIterable {
        case sitToStand = "Sit-to-Stand"
        case jumpingJacks = "Jumping Jacks"
        case squats = "Squats"
        case armRaises = "Arm Raises"
    }

    enum CalibrationState: Equatable {
        case notCalibrated
        case waitingForReady      // Waiting for user to raise arms to start
        case waitingForSit        // Waiting for user to sit and confirm
        case waitingForStand      // Waiting for user to stand and confirm
        case calibrated
    }

    private let poseRequest = VNDetectHumanBodyPoseRequest()

    // MARK: - Initialization

    init() {
        loadCalibration()
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

            // Only restore if values seem valid (non-zero and different)
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

    /// Process a frame and detect poses
    func detectPose(in cgImage: CGImage) {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([poseRequest])

            guard let observation = poseRequest.results?.first else {
                DispatchQueue.main.async {
                    self.isPersonDetected = false
                    self.currentPose = nil
                    self.poseDescription = "No person detected"
                }
                return
            }

            let pose = extractPose(from: observation)

            DispatchQueue.main.async {
                self.currentPose = pose
                self.isPersonDetected = true
                self.updatePoseDescription(pose)
                self.processCalibration(pose)
                self.trackExercise(pose)
            }

        } catch {
            print("Pose detection error: \(error)")
        }
    }

    // MARK: - Audio Feedback

    private func speak(_ text: String) {
        speechSynthesizer.stopSpeaking()
        speechSynthesizer.startSpeaking(text)
    }

    private func playBeep() {
        NSSound.beep()
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

        // If gesture reset is required, wait for hands to leave hips for required duration
        if gestureResetRequired {
            if !handsCurrentlyOnHips {
                // Start tracking release time if not already
                if gestureReleaseStartTime == nil {
                    gestureReleaseStartTime = Date()
                } else if let releaseStart = gestureReleaseStartTime,
                          Date().timeIntervalSince(releaseStart) >= gestureReleaseDuration {
                    // Hands have been off long enough - can now detect next gesture
                    gestureResetRequired = false
                    gestureReleaseStartTime = nil
                    armsRaisedStartTime = nil
                    armsWereRaised = false
                }
            } else {
                // Hands back on hips - reset release timer
                gestureReleaseStartTime = nil
            }
            return // Don't process gesture until reset
        }

        // Detect hands on hips gesture with hold duration
        if handsCurrentlyOnHips {
            if armsRaisedStartTime == nil {
                armsRaisedStartTime = Date()
            } else if let startTime = armsRaisedStartTime,
                      Date().timeIntervalSince(startTime) >= gestureHoldDuration,
                      !armsWereRaised {
                // Gesture held long enough - trigger action
                armsWereRaised = true
                handleCalibrationGesture(pose)
            }
        } else {
            // Hands moved - reset
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
            gestureResetRequired = true // Must release gesture before next step

        case .waitingForSit:
            playBeep()
            sittingHipY = hipY
            calibrationState = .waitingForStand
            calibrationMessage = "Sitting saved! Release, stand up, hands on hips"
            speak("Sitting position saved. Release your hands, stand up, then put hands on hips again")
            resetGestureState()
            gestureResetRequired = true // Must release gesture before next step

        case .waitingForStand:
            playBeep()
            standingHipY = hipY
            calibrationState = .calibrated
            isCalibrated = true
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

    /// Check if in calibrated sitting zone (with hysteresis)
    /// Must be within 85% of the calibrated sitting position
    func isInSittingZone(_ pose: DetectedPose) -> Bool {
        guard isCalibrated, let hipY = pose.hipY else { return false }

        // Calculate the range between sitting and standing
        let range = abs(standingHipY - sittingHipY)
        // Sitting threshold: must be close to calibrated sitting position
        // sittingHipY is lower (sitting), standingHipY is higher (standing)
        let sittingThreshold = sittingHipY + (range * (1 - hysteresisPercent))

        return hipY <= sittingThreshold
    }

    /// Check if in calibrated standing zone (with hysteresis)
    /// Must be within 85% of the calibrated standing position
    func isInStandingZone(_ pose: DetectedPose) -> Bool {
        guard isCalibrated, let hipY = pose.hipY else { return false }

        // Calculate the range between sitting and standing
        let range = abs(standingHipY - sittingHipY)
        // Standing threshold: must be close to calibrated standing position
        let standingThreshold = standingHipY - (range * (1 - hysteresisPercent))

        return hipY >= standingThreshold
    }

    /// Get current position as percentage (0% = sitting, 100% = standing)
    func getPositionPercent(_ pose: DetectedPose) -> CGFloat? {
        guard isCalibrated, let hipY = pose.hipY else { return nil }

        let range = standingHipY - sittingHipY
        guard range != 0 else { return nil }

        let percent = (hipY - sittingHipY) / range * 100
        return max(0, min(100, percent))
    }

    private func extractPose(from observation: VNHumanBodyPoseObservation) -> DetectedPose {
        var pose = DetectedPose()
        pose.confidence = observation.confidence

        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .leftEye, .rightEye, .leftEar, .rightEar,
            .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
            .leftWrist, .rightWrist, .leftHip, .rightHip,
            .leftKnee, .rightKnee, .leftAnkle, .rightAnkle
        ]

        for jointName in jointNames {
            if let point = try? observation.recognizedPoint(jointName),
               point.confidence > 0.3 {
                pose.joints[jointName] = CGPoint(x: point.location.x, y: point.location.y)
            }
        }

        return pose
    }

    private func updatePoseDescription(_ pose: DetectedPose) {
        var descriptions: [String] = []

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
        // Don't track during calibration
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

    /// State machine for sit-to-stand exercise
    /// Flow: standing -> goingDown -> holdingSit -> sitting -> goingUp -> standing (count rep!)
    private func trackSitToStand(_ pose: DetectedPose) {
        guard isCalibrated, let currentHipY = pose.hipY else { return }

        let inSittingZone = isInSittingZone(pose)
        let inStandingZone = isInStandingZone(pose)

        switch exerciseState {
        case .standing:
            // Waiting for user to leave standing zone (start going down)
            if !inStandingZone {
                exerciseState = .goingDown
                sittingStartTime = nil
                // Reset tracking for new rep
                lowestHipYInRep = currentHipY
                highestHipYInRep = currentHipY
            }

        case .goingDown:
            // Track lowest point reached
            lowestHipYInRep = min(lowestHipYInRep, currentHipY)

            // User is moving down, waiting to reach sitting zone
            if inSittingZone {
                // Reached sitting zone, start hold timer
                exerciseState = .holdingSit
                sittingStartTime = Date()
            } else if inStandingZone {
                // Went back to standing without reaching sitting - reset
                exerciseState = .standing
                sittingStartTime = nil
            }

        case .holdingSit:
            // Track lowest point reached
            lowestHipYInRep = min(lowestHipYInRep, currentHipY)

            // User must hold in sitting zone for required duration
            if inSittingZone {
                if let startTime = sittingStartTime,
                   Date().timeIntervalSince(startTime) >= sittingHoldDuration {
                    // Held long enough - sitting confirmed!
                    exerciseState = .sitting
                    playBeep() // Audio feedback for reaching sitting position
                    // Capture sitting photo (for the upcoming rep)
                    onCapturePhoto?(exerciseCount + 1, "sitting")
                }
            } else {
                // Left sitting zone before hold completed - go back to goingDown
                exerciseState = .goingDown
                sittingStartTime = nil
            }

        case .sitting:
            // Track lowest point reached
            lowestHipYInRep = min(lowestHipYInRep, currentHipY)

            // User is sitting, waiting for them to start going up
            if !inSittingZone {
                exerciseState = .goingUp
                highestHipYInRep = currentHipY // Start tracking highest point
            }

        case .goingUp:
            // Track highest point reached
            highestHipYInRep = max(highestHipYInRep, currentHipY)

            // User is moving up, waiting to reach standing zone
            if inStandingZone {
                // Calculate score before counting rep
                let score = calculateRepScore()

                // Completed the rep!
                exerciseCount += 1
                lastRepScore = score
                repScores.append(score)

                // Announce rep and score
                speak("\(exerciseCount), \(score) percent")

                // Capture standing photo (rep completed)
                onCapturePhoto?(exerciseCount, "standing")
                onRepCompleted?(exerciseCount, score)

                exerciseState = .standing
                sittingStartTime = nil
            } else if inSittingZone {
                // Went back down to sitting - reset to sitting state
                exerciseState = .holdingSit
                sittingStartTime = Date()
            }
        }
    }

    /// Calculate score 0-100 based on how close to ideal positions
    private func calculateRepScore() -> Int {
        let range = standingHipY - sittingHipY
        guard range > 0 else { return 0 }

        // Sitting score: how close did lowestHipY get to sittingHipY? (lower = better)
        let sittingDeviation = lowestHipYInRep - sittingHipY
        let sittingScore = max(0, 1 - (sittingDeviation / range))

        // Standing score: how close did highestHipY get to standingHipY? (higher = better)
        let standingDeviation = standingHipY - highestHipYInRep
        let standingScore = max(0, 1 - (standingDeviation / range))

        // Average both scores, convert to 0-100
        let totalScore = ((sittingScore + standingScore) / 2) * 100
        return Int(min(100, max(0, totalScore)))
    }

    /// Simple exercise tracking (original logic for jumping jacks, squats, arm raises)
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

        // Count a rep when transitioning from active to rest position
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
        lastRepScore = 0
        repScores.removeAll()
        lowestHipYInRep = 1.0
        highestHipYInRep = 0.0
    }

    func setExercise(_ exercise: ExerciseType) {
        currentExercise = exercise
        resetCount()
    }

    /// Get exercise state description for UI
    func getExerciseStateDescription() -> String {
        guard currentExercise == .sitToStand && isCalibrated else {
            return ""
        }
        return exerciseState.rawValue
    }
}

/// View that draws pose overlay on camera preview
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
                    for (_, point) in pose.joints {
                        let screenPoint = CGPoint(
                            x: point.x * scaleX,
                            y: (1 - point.y) * scaleY // Flip Y coordinate
                        )

                        context.fill(
                            Circle().path(in: CGRect(x: screenPoint.x - 5, y: screenPoint.y - 5, width: 10, height: 10)),
                            with: .color(.green)
                        )
                    }
                }
            }
        }
    }

    private func drawSkeleton(context: GraphicsContext, pose: DetectedPose, scaleX: CGFloat, scaleY: CGFloat) {
        let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
            (.leftShoulder, .rightShoulder),
            (.leftShoulder, .leftElbow),
            (.leftElbow, .leftWrist),
            (.rightShoulder, .rightElbow),
            (.rightElbow, .rightWrist),
            (.leftShoulder, .leftHip),
            (.rightShoulder, .rightHip),
            (.leftHip, .rightHip),
            (.leftHip, .leftKnee),
            (.leftKnee, .leftAnkle),
            (.rightHip, .rightKnee),
            (.rightKnee, .rightAnkle)
        ]

        for (start, end) in connections {
            guard let startPoint = pose.joints[start],
                  let endPoint = pose.joints[end] else {
                continue
            }

            let p1 = CGPoint(x: startPoint.x * scaleX, y: (1 - startPoint.y) * scaleY)
            let p2 = CGPoint(x: endPoint.x * scaleX, y: (1 - endPoint.y) * scaleY)

            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)

            context.stroke(path, with: .color(.green), lineWidth: 2)
        }
    }
}
