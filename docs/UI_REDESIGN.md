# XtremePomodoro UI Redesign Guide

> **Target Platform:** macOS 26+ / iOS 26+ with Liquid Glass Design Language
> **Last Updated:** December 2025

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Deprecated APIs to Replace](#deprecated-apis-to-replace)
3. [Liquid Glass Design System](#liquid-glass-design-system)
4. [Modern SwiftUI Patterns](#modern-swiftui-patterns)
5. [Detailed Redesign Specifications](#detailed-redesign-specifications)
6. [Gamification System](#gamification-system)
7. [Animation Guidelines](#animation-guidelines)
8. [Onboarding Video System](#onboarding-video-system)
9. [Implementation Checklist](#implementation-checklist)

---

## Executive Summary

This document provides comprehensive instructions for transforming XtremePomodoro into a modern, gamified fitness app using Apple's Liquid Glass design language and the latest SwiftUI 2025 patterns. The goal is to create an engaging experience that defeats sedentarism through beautiful UI, compelling animations, and game mechanics.

### Design Vision
- **Aesthetic:** Liquid Glass with real-time light bending, translucent materials
- **Feel:** Fluid, responsive, delightful micro-interactions
- **Purpose:** Make exercise breaks feel rewarding, not punishing

---

## Deprecated APIs to Replace

### Critical: Migrate from ObservableObject to @Observable

**Current Code (AppState.swift):**
```swift
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .pomodoro
    @Published var showExerciseOverlay: Bool = false
    // ... more @Published properties
}
```

**Modern Replacement:**
```swift
@Observable
class AppState {
    var currentScreen: Screen = .pomodoro
    var showExerciseOverlay: Bool = false
    // No @Published needed - all properties are automatically observed
}
```

### View Updates Required

| Old Pattern | New Pattern |
|-------------|-------------|
| `@StateObject private var appState = AppState()` | `@State private var appState = AppState()` |
| `@EnvironmentObject var appState: AppState` | `@Environment(AppState.self) var appState` |
| `.environmentObject(appState)` | `.environment(appState)` |
| `@ObservedObject var timer: PomodoroTimer` | Remove - use `@Environment` or pass as binding |

### TTS Service Enhancements

**Current Implementation:** Basic `AVSpeechSynthesizer` with default voice

**Enhanced Implementation:**
```swift
import AVFoundation

@Observable
final class EnhancedTTSService {
    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool { synthesizer.isSpeaking }

    // Use SSML for better prosody control (iOS 16+)
    func speak(_ text: String, emphasis: Bool = false) {
        synthesizer.stopSpeaking(at: .immediate)

        // Use SSML for natural speech patterns
        let ssml = """
        <speak>
            <prosody rate="medium" pitch="+0%">
                \(emphasis ? "<emphasis level=\"strong\">" : "")\(text)\(emphasis ? "</emphasis>" : "")
            </prosody>
        </speak>
        """

        if let utterance = AVSpeechUtterance(ssmlRepresentation: ssml) {
            // Try to use enhanced voices
            if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.premium.en-US.Zoe") {
                utterance.voice = voice
            }
            synthesizer.speak(utterance)
        } else {
            // Fallback to plain text
            let utterance = AVSpeechUtterance(string: text)
            synthesizer.speak(utterance)
        }
    }

    // Support Personal Voice (iOS 17+)
    func requestPersonalVoice() async -> Bool {
        let status = await AVSpeechSynthesizer.requestPersonalVoiceAuthorization()
        return status == .authorized
    }

    func getPersonalVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
    }
}
```

### Vision API - Already Modern
The current `PoseDetector.swift` already uses the modern Swift Vision API:
- `DetectHumanBodyPoseRequest` (2D)
- `DetectHumanBodyPose3DRequest` (3D)

No changes needed for pose detection.

---

## Liquid Glass Design System

### Core Principles

1. **Translucency:** UI elements should feel like they float above content
2. **Light Response:** Real-time light bending and specular highlights
3. **Motion Adaptation:** Elements respond to device motion and user interaction
4. **Depth:** Layered glass surfaces create visual hierarchy

### Key APIs

```swift
// Basic glass effect
.glassEffect(.regular, in: .capsule)

// Glass with tint
.glassEffect(.regular.tint(.blue), in: RoundedRectangle(cornerRadius: 16))

// Interactive glass (iOS only - for buttons, controls)
.glassEffect(.regular.interactive(), in: .circle)

// Clear glass (for media-heavy backgrounds)
.glassEffect(.clear, in: .rect(cornerRadius: 20))

// Button style
.buttonStyle(.glass)
.buttonBorderShape(.capsule)

// Container for grouped glass elements
GlassEffectContainer(spacing: 12) {
    Button("Start") { }
        .buttonStyle(.glass)
        .glassEffectID("start", in: namespace)

    Button("Settings") { }
        .buttonStyle(.glass)
        .glassEffectID("settings", in: namespace)
}
```

### Morphing Animations

```swift
struct MorphingExample: View {
    @Namespace private var namespace
    @State private var isExpanded = false

    var body: some View {
        GlassEffectContainer {
            if isExpanded {
                // Expanded state
                VStack {
                    Text("25:00")
                        .font(.system(size: 72, weight: .thin))
                    // ... controls
                }
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32))
                .glassEffectID("timer", in: namespace)
            } else {
                // Compact state
                Text("25:00")
                    .glassEffect(.regular, in: .capsule)
                    .glassEffectID("timer", in: namespace)
            }
        }
        .onTapGesture {
            withAnimation(.spring(duration: 0.5)) {
                isExpanded.toggle()
            }
        }
    }
}
```

---

## Modern SwiftUI Patterns

### App Structure

```swift
@main
struct XtremePomodoroApp: App {
    @State private var appState = AppState()
    @State private var pomodoroTimer = PomodoroTimer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(pomodoroTimer)
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { newSize in
                    appState.windowSize = newSize
                }
        }
    }
}
```

### Flexible Header (Stretchy Scroll Views)

```swift
// Create custom modifiers like the Landmarks demo
@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

private struct FlexibleHeaderContentModifier: ViewModifier {
    @Environment(AppState.self) private var appState
    @Environment(FlexibleHeaderGeometry.self) private var geometry

    func body(content: Content) -> some View {
        let height = (appState.windowSize.height / 2) - geometry.offset
        content
            .frame(height: height)
            .padding(.bottom, geometry.offset)
            .offset(y: geometry.offset)
    }
}

private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var geometry = FlexibleHeaderGeometry()

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(geometry.contentOffset.y + geometry.contentInsets.top, 0)
            } action: { _, offset in
                geometry.offset = offset
            }
            .environment(geometry)
    }
}

extension ScrollView {
    func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

extension View {
    func flexibleHeaderContent() -> some View {
        modifier(FlexibleHeaderContentModifier())
    }
}
```

### Container Relative Sizing

```swift
// Size relative to parent container
CameraPreviewView()
    .containerRelativeFrame(.vertical) { height, axis in
        height * 0.6  // Take 60% of available height
    }
```

---

## Detailed Redesign Specifications

### 1. Main Timer View (PomodoroView)

**Current:** Basic circular progress with solid colors

**Redesign:**
```swift
struct PomodoroView: View {
    @Environment(AppState.self) private var appState
    @Environment(PomodoroTimer.self) private var timer
    @Namespace private var timerNamespace

    var body: some View {
        ZStack {
            // Animated gradient background that shifts with time
            MeshGradient(
                width: 3, height: 3,
                points: animatedGradientPoints,
                colors: timerGradientColors
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Glass toolbar
                GlassEffectContainer {
                    HStack {
                        Text("XtremePomodoro")
                            .font(.headline)
                        Spacer()
                        Button(action: { appState.showSettings = true }) {
                            Image(systemName: "gear")
                        }
                        .buttonStyle(.glass)
                        .glassEffectID("settings", in: timerNamespace)
                    }
                    .padding()
                    .glassEffect(.regular, in: .capsule)
                }

                Spacer()

                // Timer with glass effect
                ZStack {
                    // Outer glass ring
                    Circle()
                        .stroke(lineWidth: 20)
                        .glassEffect(.clear, in: .circle)

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(
                            AngularGradient(
                                colors: [.cyan, .blue, .purple],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    // Center content
                    VStack(spacing: 8) {
                        Text(timer.sessionType.emoji)
                            .font(.system(size: 40))

                        Text(timer.timeString)
                            .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())

                        Text(timer.sessionType.label)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 320, height: 320)
                .glassEffectID("mainTimer", in: timerNamespace)

                // Control buttons with glass
                GlassEffectContainer(spacing: 16) {
                    if timer.timerState == .idle {
                        Button(action: { timer.startWorkSession() }) {
                            Label("Start Focus", systemImage: "play.fill")
                                .font(.title3)
                                .frame(width: 160, height: 50)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .glassEffectID("startButton", in: timerNamespace)
                    } else {
                        HStack(spacing: 12) {
                            Button(action: { timer.togglePause() }) {
                                Image(systemName: timer.timerState == .running ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .frame(width: 60, height: 50)
                            }
                            .buttonStyle(.glass)
                            .glassEffectID("pauseButton", in: timerNamespace)

                            Button(action: { timer.reset() }) {
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .frame(width: 60, height: 50)
                            }
                            .buttonStyle(.glass)
                            .glassEffectID("stopButton", in: timerNamespace)
                        }
                    }
                }

                Spacer()

                // Stats bar
                statsBar
            }
            .padding()
        }
    }

    private var statsBar: some View {
        HStack(spacing: 24) {
            StatItem(value: "\(appState.totalSessionsCompleted)", label: "Sessions", icon: "flame.fill")
            Divider().frame(height: 40)
            StatItem(value: "\(appState.currentStreak)", label: "Streak", icon: "bolt.fill")
            Divider().frame(height: 40)
            StatItem(value: "\(appState.totalRepsCompleted)", label: "Total Reps", icon: "figure.stand")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .glassEffect(.regular, in: .capsule)
    }
}
```

### 2. Exercise Overlay View

**Current:** Dark background with basic camera preview

**Redesign - Immersive Exercise Arena:**
```swift
struct ExerciseOverlayView: View {
    @Environment(AppState.self) private var appState
    @StateObject private var cameraCapture = CameraCapture()
    @StateObject private var poseDetector = PoseDetector()
    @Namespace private var exerciseNamespace

    @State private var showConfetti = false
    @State private var currentPower: Double = 0

    var body: some View {
        ZStack {
            // Dynamic background based on progress
            MeshGradient(
                width: 3, height: 3,
                points: [
                    // Animated points based on rep progress
                ],
                colors: exerciseGradientColors
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with power meter
                topBar

                // Main camera view with AR overlay
                mainCameraView

                // Bottom controls
                bottomControls
            }

            // Floating badges (achievement pop-ups)
            FloatingBadgesView()

            // Confetti on completion
            if showConfetti {
                ConfettiView()
            }
        }
    }

    private var topBar: some View {
        HStack {
            // Rep counter with glass
            VStack(alignment: .leading, spacing: 4) {
                Text("REPS")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(repsCompleted)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    Text("/ \(repsRequired)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))

            Spacer()

            // Power meter / score
            VStack(alignment: .trailing, spacing: 4) {
                Text("POWER")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PowerMeterView(power: currentPower)
                    .frame(width: 120, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
        }
        .padding()
    }

    private var mainCameraView: some View {
        ZStack {
            // Camera feed
            CameraPreviewView(cameraCapture: cameraCapture)
                .overlay {
                    // Pose skeleton overlay
                    if showPoseOverlay {
                        PoseOverlayView(pose: poseDetector.currentPose)
                    }

                    // AR exercise guides
                    ExerciseGuideOverlay(
                        exercise: poseDetector.currentExercise,
                        state: poseDetector.exerciseState
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            isComplete ? Color.green : progressBorderColor,
                            lineWidth: 4
                        )
                )
                .shadow(color: progressBorderColor.opacity(0.5), radius: 20)
        }
        .containerRelativeFrame(.vertical) { height, _ in
            height * 0.6
        }
        .padding(.horizontal)
    }

    private var bottomControls: some View {
        VStack(spacing: 20) {
            // Exercise state indicator
            ExerciseStateIndicator(state: poseDetector.exerciseState)

            // Motivational message
            Text(motivationalMessage)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Action button (on completion)
            if isComplete {
                Button(action: { completeExercise() }) {
                    Label("Continue Working", systemImage: "arrow.right.circle.fill")
                        .font(.title2)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .glassEffectID("continueButton", in: exerciseNamespace)
            }
        }
        .padding()
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32))
        .padding()
    }
}
```

### 3. Onboarding Flow

**Current:** Basic step-by-step wizard

**Redesign - Cinematic Onboarding:**
```swift
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentStep = 0
    @Namespace private var onboardingNamespace

    var body: some View {
        ZStack {
            // Video background for immersion
            if let videoURL = Bundle.main.url(forResource: "onboarding_bg", withExtension: "mp4") {
                VideoPlayerView(url: videoURL, isLooping: true)
                    .ignoresSafeArea()
                    .opacity(0.3)
            }

            // Glass container for content
            VStack(spacing: 0) {
                // Progress indicator
                OnboardingProgressView(
                    currentStep: currentStep,
                    totalSteps: totalSteps
                )
                .padding(.top)

                // Step content
                TabView(selection: $currentStep) {
                    WelcomeStep()
                        .tag(0)
                        .glassEffectID("welcome", in: onboardingNamespace)

                    CameraSetupStep()
                        .tag(1)
                        .glassEffectID("camera", in: onboardingNamespace)

                    ExerciseSelectionStep()
                        .tag(2)
                        .glassEffectID("exercise", in: onboardingNamespace)

                    CalibrationStep()
                        .tag(3)
                        .glassEffectID("calibration", in: onboardingNamespace)

                    ReadyStep()
                        .tag(4)
                        .glassEffectID("ready", in: onboardingNamespace)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation
                OnboardingNavigation(
                    currentStep: $currentStep,
                    totalSteps: totalSteps,
                    canProceed: canProceedFromCurrentStep
                )
                .padding()
            }
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 40))
            .padding(40)
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 40) {
            // Animated logo
            AnimatedLogoView()
                .frame(width: 200, height: 200)

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("XtremePomodoro")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Text("Transform your breaks into power-ups")
                .font(.title3)
                .foregroundStyle(.secondary)

            // Feature highlights with icons
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "timer",
                    title: "Smart Timer",
                    description: "Pomodoro technique for peak focus"
                )
                FeatureRow(
                    icon: "figure.run",
                    title: "Movement Tracking",
                    description: "AI-powered exercise detection"
                )
                FeatureRow(
                    icon: "trophy.fill",
                    title: "Gamified Progress",
                    description: "Earn XP, unlock achievements"
                )
            }
            .padding(.top, 20)
        }
        .padding(40)
    }
}
```

---

## Gamification System

### XP and Leveling

```swift
@Observable
class GamificationState {
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var unlockedAchievements: Set<Achievement.ID> = []
    var earnedBadges: [Badge] = []

    // XP required for each level (exponential curve)
    func xpForLevel(_ level: Int) -> Int {
        Int(100 * pow(1.5, Double(level - 1)))
    }

    var currentLevelProgress: Double {
        let currentLevelXP = xpForLevel(currentLevel)
        let previousLevelXP = currentLevel > 1 ? xpForLevel(currentLevel - 1) : 0
        let xpInCurrentLevel = totalXP - previousLevelXP
        let xpNeededForLevel = currentLevelXP - previousLevelXP
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }

    // Award XP for various actions
    func awardXP(for action: XPAction) {
        let xpAmount: Int
        switch action {
        case .completedRep(let score):
            xpAmount = 10 + (score / 10) // 10-20 XP per rep
        case .completedSession:
            xpAmount = 50
        case .perfectSession: // All reps 90%+ score
            xpAmount = 100
        case .maintainedStreak(let days):
            xpAmount = days * 20
        case .unlockedAchievement:
            xpAmount = 200
        }

        totalXP += xpAmount
        checkLevelUp()
    }

    enum XPAction {
        case completedRep(score: Int)
        case completedSession
        case perfectSession
        case maintainedStreak(days: Int)
        case unlockedAchievement
    }
}
```

### Achievement System

```swift
struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let rarity: Rarity
    let requirement: Requirement

    enum Rarity: String, CaseIterable {
        case common, rare, epic, legendary

        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
    }

    enum Requirement {
        case totalReps(Int)
        case totalSessions(Int)
        case streak(Int)
        case perfectReps(Int)
        case totalXP(Int)
    }
}

// Example achievements
let achievements: [Achievement] = [
    Achievement(
        id: "first_rep",
        name: "First Steps",
        description: "Complete your first exercise rep",
        icon: "figure.walk",
        rarity: .common,
        requirement: .totalReps(1)
    ),
    Achievement(
        id: "century",
        name: "Century Club",
        description: "Complete 100 total reps",
        icon: "100.circle.fill",
        rarity: .rare,
        requirement: .totalReps(100)
    ),
    Achievement(
        id: "perfectionist",
        name: "Perfectionist",
        description: "Score 100% on 10 consecutive reps",
        icon: "star.fill",
        rarity: .epic,
        requirement: .perfectReps(10)
    ),
    Achievement(
        id: "marathon",
        name: "Marathon Champion",
        description: "Maintain a 30-day streak",
        icon: "flame.fill",
        rarity: .legendary,
        requirement: .streak(30)
    )
]
```

### Badges View (Liquid Glass Style)

```swift
struct BadgesView: View {
    @Environment(GamificationState.self) private var gamification
    @State private var isExpanded = false
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer(spacing: 8) {
            VStack(alignment: .center, spacing: 12) {
                if isExpanded {
                    VStack(spacing: 8) {
                        ForEach(gamification.earnedBadges) { badge in
                            BadgeLabel(badge: badge)
                                .glassEffect(.regular, in: .rect(cornerRadius: 12))
                                .glassEffectID(badge.id, in: namespace)
                        }
                    }
                }

                Button {
                    withAnimation(.spring(duration: 0.5)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Label(
                        isExpanded ? "Hide" : "Badges",
                        systemImage: isExpanded ? "xmark" : "star.fill"
                    )
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.glass)
                .glassEffectID("toggleBadges", in: namespace)
            }
        }
    }
}
```

---

## Animation Guidelines

### @Animatable Macro (New in iOS 26)

```swift
// Simplifies custom animations
@Animatable
struct PowerMeterShape: Shape {
    var power: Double

    // The @Animatable macro automatically synthesizes Animatable conformance
    func path(in rect: CGRect) -> Path {
        // Shape that fills based on power level
        var path = Path()
        let width = rect.width * power
        path.addRoundedRect(
            in: CGRect(x: 0, y: 0, width: width, height: rect.height),
            cornerSize: CGSize(width: 8, height: 8)
        )
        return path
    }
}
```

### Spring Animations

```swift
// Use spring animations for natural feel
withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
    isExpanded.toggle()
}

// For rep completion celebrations
withAnimation(.spring(duration: 0.6, bounce: 0.5)) {
    repScale = 1.2
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
    withAnimation(.spring(duration: 0.3)) {
        repScale = 1.0
    }
}
```

### Content Transitions

```swift
// Numeric transitions for counters
Text("\(repCount)")
    .font(.system(size: 72, weight: .bold))
    .contentTransition(.numericText())
    .animation(.spring, value: repCount)
```

### Phase Animator for Complex Sequences

```swift
struct RepCompleteCelebration: View {
    @State private var trigger = false

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(.green)
            .phaseAnimator([false, true], trigger: trigger) { content, phase in
                content
                    .scaleEffect(phase ? 1.3 : 1.0)
                    .opacity(phase ? 1.0 : 0.8)
            } animation: { phase in
                phase ? .spring(duration: 0.2, bounce: 0.5) : .spring(duration: 0.4)
            }
    }
}
```

---

## Onboarding Video System

### Video Snippet Integration

Create short (5-15 second) video clips for each onboarding step:

```swift
struct VideoPlayerView: View {
    let url: URL
    let isLooping: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player = AVPlayer(url: url)
                player?.isMuted = true
                player?.play()

                if isLooping {
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player?.currentItem,
                        queue: .main
                    ) { _ in
                        player?.seek(to: .zero)
                        player?.play()
                    }
                }
            }
            .onDisappear {
                player?.pause()
            }
    }
}

// Usage in onboarding
struct CameraSetupStep: View {
    var body: some View {
        VStack {
            // Tutorial video showing camera positioning
            if let videoURL = Bundle.main.url(forResource: "camera_setup_tutorial", withExtension: "mp4") {
                VideoPlayerView(url: videoURL, isLooping: true)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }

            Text("Position your camera to see your full body")
                .font(.title2)
                .multilineTextAlignment(.center)

            // ... actual camera preview for setup
        }
    }
}
```

### Required Video Assets

Create these video clips:

1. **welcome_loop.mp4** - Abstract fitness/tech animation (background)
2. **camera_setup_tutorial.mp4** - Shows ideal camera positioning
3. **sit_to_stand_demo.mp4** - Demonstrates proper sit-to-stand form
4. **squat_demo.mp4** - Demonstrates proper squat form
5. **jumping_jack_demo.mp4** - Demonstrates jumping jacks
6. **calibration_tutorial.mp4** - Shows calibration process
7. **rep_celebration.mp4** - Short celebration animation

---

## Implementation Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Migrate `AppState` to `@Observable` macro
- [ ] Migrate `PomodoroTimer` to `@Observable` macro
- [ ] Update all views to use `@Environment` instead of `@EnvironmentObject`
- [ ] Create `GamificationState` observable
- [ ] Set up UserDefaults/SwiftData persistence for gamification data

### Phase 2: Liquid Glass UI (Week 2-3)
- [ ] Add `.glassEffect()` to all major UI components
- [ ] Implement `GlassEffectContainer` groupings
- [ ] Add morphing animations with `@Namespace` and `.glassEffectID()`
- [ ] Update buttons to use `.buttonStyle(.glass)`
- [ ] Implement flexible header scroll views
- [ ] Add mesh gradient backgrounds

### Phase 3: Timer Redesign (Week 3)
- [ ] Redesign `PomodoroView` with glass timer ring
- [ ] Add animated gradient background
- [ ] Implement stats bar with glass styling
- [ ] Add content transitions for timer numbers

### Phase 4: Exercise Arena (Week 4)
- [ ] Redesign `ExerciseOverlayView` with immersive look
- [ ] Add power meter visualization
- [ ] Implement exercise state indicators with animations
- [ ] Add AR-style exercise guides overlay
- [ ] Implement confetti/celebration effects

### Phase 5: Gamification (Week 5)
- [ ] Implement XP awarding logic
- [ ] Create level-up animations and notifications
- [ ] Build achievement system
- [ ] Implement badge display with Liquid Glass
- [ ] Add streak tracking

### Phase 6: Onboarding (Week 6)
- [ ] Create/source video assets
- [ ] Redesign onboarding with video backgrounds
- [ ] Implement cinematic step transitions
- [ ] Add interactive tutorials

### Phase 7: TTS Enhancement
- [ ] Implement SSML-based speech
- [ ] Add PersonalVoice support
- [ ] Create motivational message library
- [ ] Add voice coaching during exercises

### Phase 8: Polish (Week 7)
- [ ] Performance optimization
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Reduce motion support
- [ ] Localization preparation
- [ ] Beta testing and refinement

---

## Resources

- [Apple Liquid Glass Design](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [WWDC25: Build with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [SwiftUI iOS 26 Features](https://www.infoq.com/news/2025/06/swiftui-ios26-liquid-glass/)
- [Liquid Glass Reference](https://github.com/conorluddy/LiquidGlassReference)
- [Migrating to @Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Personal Voice API](https://developer.apple.com/videos/play/wwdc2023/10033/)

---

## Summary

This redesign transforms XtremePomodoro from a functional utility into an engaging, gamified experience. Key transformations:

1. **Visual:** Liquid Glass materials create depth and elegance
2. **State Management:** Modern `@Observable` macro for better performance
3. **Gamification:** XP, levels, achievements, and streaks drive engagement
4. **Animations:** Spring physics, morphing transitions, and celebrations
5. **Onboarding:** Video-enhanced, cinematic introduction
6. **Voice:** Enhanced TTS with SSML and personal voice support

The result will be an app that makes users *want* to take exercise breaks, turning what could feel like an interruption into a rewarding game experience.
