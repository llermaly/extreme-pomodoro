# XtremePomodoro Design Directives
## UI/UX Experience Guidelines for Apple LiquidGlass Era

**Version:** 1.0
**Date:** December 2025
**Target Platforms:** macOS Tahoe 26+, iOS 26+

---

## Executive Summary

XtremePomodoro is a fitness-focused Pomodoro timer with computer vision-based exercise tracking, voice coaching, and comprehensive session history. This document provides design directives aligned with Apple's LiquidGlass design language while incorporating best practices from market-leading productivity apps.

---

## 1. Design Philosophy

### 1.1 Core Principles

| Principle | Implementation |
|-----------|----------------|
| **Translucency First** | All containers use LiquidGlass material that reflects/refracts surroundings |
| **Content Focus** | Controls shrink and morph to prioritize user content and timer state |
| **Dynamic Response** | UI elements react to motion with specular highlights |
| **Adaptive Color** | Interface adapts intelligently between light/dark environments |
| **Concentric Harmony** | UI elements fit perfectly with rounded hardware corners |

### 1.2 Color System

```
Primary Work State:     #007AFF (Blue)  - Active focus sessions
Primary Break State:    #34C759 (Green) - Breaks and completions
Warning/Attention:      #FF9500 (Orange) - Calibration needed
Error/Cancelled:        #FF3B30 (Red)   - Failed sessions
Secondary Actions:      #AF52DE (Purple) - Non-primary controls

LiquidGlass Materials:
- glassBackground:      Dynamic, context-aware translucency
- glassBorder:          Subtle edge definition with refraction
- glassHighlight:       Specular reflections on interaction
```

---

## 2. Feature-Specific Directives

### 2.1 Big Engaging Onboarding

**Objective:** Create an emotionally resonant first-run experience that establishes trust and reduces friction for camera/exercise setup.

#### Visual Design

```
+------------------------------------------------------------------+
|                                                                  |
|                    [LiquidGlass Hero Card]                       |
|                                                                  |
|              +---------------------------------+                  |
|              |                                 |                  |
|              |    [Animated Illustration]      |                  |
|              |    Translucent, layered,        |                  |
|              |    refracts wallpaper           |                  |
|              |                                 |                  |
|              +---------------------------------+                  |
|                                                                  |
|                   "Transform Your Breaks"                         |
|                                                                  |
|              Subtle, weighted San Francisco Pro                   |
|                                                                  |
|              [ LiquidGlass CTA Button ]                          |
|              Specular highlights on hover                        |
|                                                                  |
|              . . o . .  (Progress dots, glass material)          |
|                                                                  |
+------------------------------------------------------------------+
```

#### Onboarding Flow (5 Steps)

| Step | Screen | Content | Interaction |
|------|--------|---------|-------------|
| 1 | **Welcome** | Hero animation showing work-to-exercise transition | Swipe or tap to continue |
| 2 | **Work Schedule** | Interactive time picker with glass sliders | Drag to set start/end times |
| 3 | **Exercise Selection** | Grid of exercise types with preview animations | Tap to select, shows demo |
| 4 | **Camera Calibration** | Live camera feed with pose overlay | Guided positioning with voice |
| 5 | **Ready** | Success celebration with first session preview | Launch into main experience |

#### Design Specifications

- **Hero Cards:** Full-width LiquidGlass containers with 24pt corner radius
- **Typography:** SF Pro Display for headlines (40pt), SF Pro Text for body (17pt)
- **Animations:**
  - Page transitions: 0.4s spring ease with parallax depth
  - Illustrations: Looping Lottie animations with glass overlay
  - Progress dots: Morphing glass circles that expand on current step
- **Gamification Inspiration (from Forest):** Consider subtle "growing" metaphor - each completed step "grows" your productivity foundation

#### Accessibility

- VoiceOver labels for all interactive elements
- Reduce Motion: Replace parallax with crossfades
- High Contrast: Increase glass opacity to 85%

---

### 2.2 Small Clock for Capture Mode

**Objective:** Provide an unobtrusive, always-visible timer during focused work that doesn't distract from primary tasks.

#### Design Concept

```
Compact Mode (During Work Session):

    +-------------------+
    |  [Glass Pill]     |
    |   25:00           |  <-- Monospace SF Mono
    |   ● Working       |  <-- Status indicator
    +-------------------+
         ↑
    Floating window,
    always on top,
    draggable position
```

#### Visual Specifications

| Property | Value |
|----------|-------|
| **Container** | Pill-shaped LiquidGlass (height: 48pt, min-width: 100pt) |
| **Corner Radius** | 24pt (full pill) |
| **Background** | Ultra-thin glass material (0.3 opacity blur) |
| **Border** | 1pt glass border with subtle refraction |
| **Timer Font** | SF Mono Medium, 20pt, high contrast |
| **Status Dot** | 8pt circle, pulsing animation on active |

#### Behaviors

- **Hover:** Expands slightly to reveal pause/skip controls
- **Click-through:** Option to make non-interactive except for double-click
- **Position Memory:** Saves last position per display
- **Context Adaptation:** Glass tints based on underlying window content
- **Break Transition:** Morphs color from blue to green when break starts

#### Implementation Note

Reference Focus Keeper's "lively and colorful background that helps users visualize the time elapsed" - consider subtle gradient progress within the glass material.

---

### 2.3 Top Right Timer in Toolbar (Menu Bar)

**Objective:** Persistent, glanceable timer state in the macOS menu bar that respects system-wide LiquidGlass aesthetics.

#### Design Concept

```
macOS Menu Bar (Tahoe 26 - Transparent):

    [WiFi] [Battery] [25:00 ●] [Control Center]
                        ↑
                  XtremePomodoro
                  Menu Bar Item
```

#### Menu Bar Icon States

| State | Display | Color |
|-------|---------|-------|
| **Idle** | Tomato icon (outline) | System secondary |
| **Working** | `MM:SS` + filled tomato | Blue accent |
| **Break** | `MM:SS` + exercise icon | Green accent |
| **Paused** | `MM:SS` + pause badge | Orange accent |

#### Dropdown Menu Design

```
+--------------------------------+
|  [LiquidGlass Menu Container]  |
|                                |
|  Current Session               |
|  +--------------------------+  |
|  |  25:00 remaining         |  |
|  |  [===========----] 60%   |  |  <- Glass progress bar
|  +--------------------------+  |
|                                |
|  ─────────────────────────     |
|  ▶ Resume          ⌘R         |
|  ⏭ Skip Break      ⌘S         |
|  ⏹ End Session     ⌘E         |
|  ─────────────────────────     |
|  ⚙ Settings...     ⌘,         |
|  📊 View History   ⌘H         |
|  ─────────────────────────     |
|  Quit              ⌘Q         |
+--------------------------------+
```

#### Specifications

- **Menu Width:** 280pt
- **Corner Radius:** 12pt (matches system menus in Tahoe 26)
- **Glass Material:** Standard menu material with enhanced blur
- **Progress Bar:** Glass-filled track with specular highlight at fill edge
- **Keyboard Shortcuts:** Right-aligned, secondary color

---

### 2.4 Exercise Capture View

**Objective:** Fullscreen, immersive exercise experience with real-time pose feedback and motivational UI.

#### Primary Layout

```
+------------------------------------------------------------------+
|                                                                  |
|    [LiquidGlass Header - Floats over camera]                     |
|    +----------------------------------------------------------+  |
|    |  Sit-to-Stand          3/10 reps          01:45          |  |
|    |  Exercise Name         Progress           Time Left       |  |
|    +----------------------------------------------------------+  |
|                                                                  |
|                                                                  |
|                   [ LIVE CAMERA FEED ]                           |
|                                                                  |
|                   +------------------+                           |
|                   |                  |                           |
|                   |  Pose skeleton   |                           |
|                   |  overlay with    |                           |
|                   |  glass joints    |                           |
|                   |                  |                           |
|                   +------------------+                           |
|                                                                  |
|                                                                  |
|    [LiquidGlass Footer - Rep counter + controls]                 |
|    +----------------------------------------------------------+  |
|    |                                                          |  |
|    |     [ STAND ]  <--  Current instruction, pulsing         |  |
|    |                                                          |  |
|    |  ○ ○ ● ○ ○ ○ ○ ○ ○ ○   Rep progress dots                |  |
|    |                                                          |  |
|    |            [ Skip Exercise ]                             |  |
|    +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

#### Component Specifications

**Header Bar**
- Position: Fixed top, 80pt from safe area
- Glass Material: Regular intensity, 16pt corner radius
- Height: 60pt
- Content: Exercise name (left), rep counter (center), countdown (right)

**Pose Skeleton Overlay**
- Joints: Glass circles (12pt diameter) with specular highlights
- Bones: Semi-transparent gradient lines connecting joints
- Detected State: Green tint on correctly positioned limbs
- Target Zone: Glass-bordered target area showing where to move

**Rep Counter**
- Style: Large numerals with glass depth (shadows + highlights)
- Animation: Scale bounce (1.0 → 1.2 → 1.0) on rep completion
- Sound: Satisfying "ding" with haptic feedback

**Instruction Display**
- Typography: SF Pro Rounded, 48pt, Bold
- Animation: Subtle pulse with glass shimmer
- Colors: Current action in accent color (STAND=green, SIT=blue)

**Progress Dots**
- Completed: Filled glass circle with green tint
- Current: Pulsing ring animation
- Remaining: Empty glass circle outline

#### Photo Capture Integration

- Silent shutter at rep completion (sitting and standing positions)
- Brief glass flash overlay (0.1s) to indicate capture
- Thumbnail preview in corner (optional, can be disabled)

---

### 2.5 Journal View

**Objective:** Reflective, calm interface for post-session notes that encourages mindful documentation.

#### Entry Flow

```
After Exercise Completion:

+------------------------------------------------------------------+
|                                                                  |
|                  [LiquidGlass Modal Sheet]                       |
|                                                                  |
|    +----------------------------------------------------------+  |
|    |                                                          |  |
|    |    Session Complete                                      |  |
|    |    ──────────────────                                    |  |
|    |                                                          |  |
|    |    10 reps of Sit-to-Stand                               |  |
|    |    25 minutes focused work                               |  |
|    |                                                          |  |
|    |    +--------------------------------------------------+  |  |
|    |    |                                                  |  |  |
|    |    |  How did this session go?                        |  |  |
|    |    |                                                  |  |  |
|    |    |  [Glass text area with subtle placeholder]       |  |  |
|    |    |                                                  |  |  |
|    |    |  "Reflect on your focus and energy..."           |  |  |
|    |    |                                                  |  |  |
|    |    +--------------------------------------------------+  |  |
|    |                                                          |  |
|    |    [Photo Carousel - Glass frames]                       |  |
|    |    +------+ +------+ +------+ +------+                   |  |
|    |    | Rep1 | | Rep2 | | Rep3 | | ...  |                   |  |
|    |    +------+ +------+ +------+ +------+                   |  |
|    |                                                          |  |
|    |    [ Skip ]              [ Save & Continue ]             |  |
|    |    Ghost button          Primary glass CTA               |  |
|    |                                                          |  |
|    +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

#### Historical Journal View

```
Session Detail Screen:

+------------------------------------------------------------------+
|  < Back                Session Details                    Edit   |
|  ─────────────────────────────────────────────────────────────── |
|                                                                  |
|  [Glass Card - Session Summary]                                  |
|  +--------------------------------------------------------------+|
|  |  Thursday, December 19, 2025                                 ||
|  |  2:30 PM - 2:55 PM                                           ||
|  |                                                              ||
|  |  ● 25 min focus    ● 10 reps    ● Sit-to-Stand              ||
|  +--------------------------------------------------------------+|
|                                                                  |
|  [Glass Card - Journal Entry]                                    |
|  +--------------------------------------------------------------+|
|  |                                                              ||
|  |  "Great session today. Felt energized after the             ||
|  |   exercises. Need to work on deeper squats next time."      ||
|  |                                                              ||
|  |                                        ✏️ Edit               ||
|  +--------------------------------------------------------------+|
|                                                                  |
|  [Glass Card - Photos]                                           |
|  +--------------------------------------------------------------+|
|  |  Exercise Photos                                    See All > ||
|  |                                                              ||
|  |  +--------+  +--------+  +--------+  +--------+              ||
|  |  |        |  |        |  |        |  |        |              ||
|  |  | Photo  |  | Photo  |  | Photo  |  | Photo  |              ||
|  |  |   1    |  |   2    |  |   3    |  |   4    |              ||
|  |  +--------+  +--------+  +--------+  +--------+              ||
|  +--------------------------------------------------------------+|
|                                                                  |
+------------------------------------------------------------------+
```

#### Design Specifications

**Text Area**
- Glass container with inner shadow (inset effect)
- Placeholder: SF Pro Italic, 40% opacity
- Active: Subtle glass glow border on focus
- Min height: 120pt, expands with content

**Photo Carousel**
- Horizontal scroll with momentum
- Glass frame per photo (4pt glass border)
- Corner radius: 8pt
- Size: 80x80pt thumbnails
- Tap: Expands to fullscreen with glass backdrop

**Emotion/Rating (Optional Enhancement)**
- Quick mood selector: Glass emoji buttons
- Options: Focused, Distracted, Energized, Tired, Neutral
- Single-tap selection with scale animation

---

## 3. Animation & Motion Guidelines

### 3.1 Core Principles

| Type | Duration | Curve | Use Case |
|------|----------|-------|----------|
| **Micro** | 0.15-0.2s | ease-out | Button feedback, toggles |
| **Standard** | 0.3-0.4s | spring(0.5, 0.8) | View transitions, modals |
| **Emphasis** | 0.5-0.6s | spring(0.3, 0.6) | Celebrations, completions |
| **Continuous** | 1.0-2.0s | linear/loop | Loading states, pulses |

### 3.2 LiquidGlass-Specific Animations

**Specular Highlights**
- Respond to device motion (accelerometer on iOS)
- Subtle parallax on cursor movement (macOS)
- Implementation: Gradient overlay with position tied to motion data

**Morphing Controls**
- Tab bars and controls should morph, not snap
- Use matchedGeometryEffect for shared element transitions
- Progress bars fill with liquid-like easing

**Refraction Effects**
- Background content should subtly distort through glass
- Use blur + scale transforms on underlying content
- Intensity varies with glass layer depth

### 3.3 State Transitions

```
Work → Break Transition:

1. Timer reaches 00:00 (0.0s)
2. Glass container color shifts blue → green (0.3s ease)
3. Exercise overlay slides up with spring (0.4s)
4. Camera feed fades in with glass vignette (0.3s)
5. Instruction text scales in (0.2s delay, 0.3s spring)
```

---

## 4. Competitive Differentiation

### 4.1 Features from Market Leaders to Consider

| App | Feature to Adopt | XtremePomodoro Adaptation |
|-----|------------------|---------------------------|
| **Forest** | Gamification, growing metaphor | "Build your fitness streak" - visual representation of consistency |
| **Focus Keeper** | Tomato-shaped timer visual | Glass tomato that fills with progress |
| **Focus To-Do** | Cross-platform sync | iCloud-based session sync |
| **Focus Booster** | Productivity insights dashboard | Weekly glass cards showing patterns |
| **Be Focused** | Beautiful aesthetic priority | LiquidGlass as core differentiator |

### 4.2 Unique Selling Points

1. **Exercise Integration** - No competitor combines Pomodoro with guided exercise
2. **Pose Detection** - Computer vision feedback is unique in this space
3. **Photo Memory** - Capture progress over time
4. **LiquidGlass Native** - First Pomodoro app fully designed for macOS Tahoe/iOS 26

---

## 5. Technical Implementation Notes

### 5.1 SwiftUI Materials

```swift
// LiquidGlass container modifier
.background(.ultraThinMaterial)
.background {
    // Dynamic refraction effect
    VisualEffectView(effect: .systemMaterial)
        .overlay {
            // Specular highlight layer
            LinearGradient(...)
                .blendMode(.overlay)
                .opacity(0.3)
        }
}
.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
.shadow(color: .black.opacity(0.1), radius: 20, y: 10)
```

### 5.2 Recommended Frameworks

- **SwiftUI 6** - Native LiquidGlass material support
- **CoreMotion** - Device motion for specular effects
- **Vision** - Pose detection (already implemented)
- **AVFoundation** - Camera capture (already implemented)

### 5.3 Performance Considerations

- Limit real-time blur effects to essential surfaces
- Use pre-rendered glass textures for static elements
- Reduce glass layers on older hardware (< M1)
- Cache specular highlight positions

---

## 6. Accessibility Requirements

### 6.1 Visual Accessibility

| Setting | Adaptation |
|---------|------------|
| **Reduce Transparency** | Replace glass with solid colors at 90% opacity |
| **Increase Contrast** | Darken text, add borders to glass elements |
| **Reduce Motion** | Disable specular highlights, use crossfades |
| **Larger Text** | Scale all typography, maintain glass proportions |

### 6.2 Motor Accessibility

- All controls minimum 44x44pt touch targets
- Keyboard navigation support for all views
- Voice Control labels for exercise positions
- Alternative to pose detection: manual rep counting

### 6.3 Cognitive Accessibility

- Clear, predictable navigation patterns
- Consistent iconography across views
- Optional simplified mode with reduced features
- Clear session state indication at all times

---

## 7. Design Asset Requirements

### 7.1 Icons & Symbols

| Asset | Format | Sizes | Notes |
|-------|--------|-------|-------|
| App Icon | PNG, layered | 16-1024pt | LiquidGlass tomato with depth |
| Menu Bar Icon | SF Symbol + custom | 18pt | Template mode for tinting |
| Exercise Icons | SF Symbols | 24-48pt | figure.walk, figure.stand, etc. |
| Tab Icons | SF Symbols | 24pt | Timer, calendar, settings |

### 7.2 Illustrations

- Onboarding hero illustrations (Lottie or animated PNG sequence)
- Empty state illustrations for history view
- Celebration animation for session completion
- Exercise demonstration animations

### 7.3 Sounds

| Event | Sound | Duration |
|-------|-------|----------|
| Session start | Gentle glass chime | 0.5s |
| Rep complete | Soft pop | 0.2s |
| Session complete | Celebration tone | 1.0s |
| Timer tick (optional) | Subtle tick | 0.1s |

---

## 8. User Research Priorities

### 8.1 Validate Before Implementation

1. Onboarding flow length - is 5 steps optimal?
2. Compact timer preferences - size, position, opacity
3. Journal friction - do users want to write post-session?
4. Photo usefulness - is exercise photo capture valued?

### 8.2 A/B Test Candidates

- Gamification elements (streaks, achievements)
- Timer display format (analog glass vs digital)
- Exercise instruction style (text vs animation)
- Color themes beyond blue/green

---

## Appendix A: Reference Links

### Apple LiquidGlass
- [Apple Newsroom: New Software Design](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [Apple Design Resources](https://developer.apple.com/design/resources/)

### Market Research
- [Zapier: Best Pomodoro Apps 2025](https://zapier.com/blog/best-pomodoro-apps/)
- [Reclaim: Top Pomodoro Timer Apps](https://reclaim.ai/blog/best-pomodoro-timer-apps)

---

## Appendix B: Existing Feature Inventory

Current XtremePomodoro features to maintain and enhance:

- PomodoroView - Main timer interface
- ExerciseOverlayView - Fullscreen exercise breaks
- ScheduleView - Daily progress visualization
- OnboardingView - 5-step setup wizard
- SettingsView - Configuration panel
- DaySessionsView - Session grid by day
- SessionDetailView - Session history detail
- JournalEntrySheet - Post-session notes
- MenuBarController - macOS menu bar integration
- PoseDetector - 2D/3D pose detection
- SessionPhotoManager - Exercise photo capture
- TTSService - Voice coaching

---

*Document prepared for XtremePomodoro UI/UX redesign initiative.*
*Design language aligned with Apple LiquidGlass (WWDC 2025).*
