# Movedoro

A Pomodoro timer that forces you to exercise during breaks - because sometimes we need tough love to stay healthy.

## Why This Exists

I created this app for myself because I'm very sedentary and I fear for my health. I know I won't exercise unless I'm forced to. The irony? While coding this app, I did more exercise than I had in months.

## How It Works

1. **Work Session**: Standard Pomodoro timer counts down your focus time
2. **Break Time**: When the timer ends, your computer locks until you complete your exercise
3. **Exercise Tracking**: Camera-based pose detection tracks your movements (sit-to-stand, squats, etc.)
4. **AI Scoring**: Vision AI evaluates your form and scores each rep (0-100%)
5. **AI Coach**: Voice feedback encourages you to keep pushing and maintain proper form
6. **Freedom**: Complete your reps correctly, and your computer unlocks

## Features

### Core
- Pomodoro timer with customizable work/break intervals
- Computer screen blocking during exercise breaks (no cheating!)
- Camera-based exercise detection using Apple Vision framework
- Real-time pose skeleton overlay
- Rep counting with audio feedback

### Exercise Tracking
- **Sit-to-Stand**: Calibrated to your body and furniture
- **Squats**: Track depth and form
- **Jumping Jacks**: Count full reps
- **Arm Raises**: Simple mobility exercise
- Gesture-based calibration (hands-free setup)
- Session photo gallery with per-rep scoring

### Smart Features
- OBSBOT camera integration (gimbal control, presets, zoom)
- Persistent calibration (calibrate once, use forever)
- Standing desk mode (track if you're standing while working)
- LLM-powered voice coaching and encouragement

## Requirements

- macOS 14.0+
- Camera (built-in or external)
- Optional: OBSBOT Tiny 2 for advanced camera control

## Setup

1. Launch Movedoro
2. Complete the one-time calibration for your exercise
3. Set your Pomodoro intervals
4. Start working!

## Philosophy

This isn't about being gentle with yourself. It's about building a system that makes exercise non-negotiable. Your computer literally won't let you continue working until you've moved your body.

Because sometimes the best motivation is having no other choice.

---

Built with SwiftUI, Vision framework, and desperation to be healthier.
