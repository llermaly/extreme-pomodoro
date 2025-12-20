import SwiftUI

/// Constant values for Liquid Glass styling and layout throughout the app.
struct Constants {
    // MARK: - App-wide constants

    static let cornerRadius: CGFloat = 15.0
    static let standardPadding: CGFloat = 14.0
    static let safeAreaPadding: CGFloat = 30.0

    // MARK: - Glass Effect constants

    static let glassSpacing: CGFloat = 16.0
    static let glassCornerRadius: CGFloat = 24.0
    static let glassContainerCornerRadius: CGFloat = 20.0

    // MARK: - Timer View constants

    static let timerSize: CGFloat = 280.0
    static let timerStrokeWidth: CGFloat = 12.0
    static let timerFontSize: CGFloat = 72.0
    static let statBarCornerRadius: CGFloat = 16.0
    static let statBarPadding: CGFloat = 16.0

    // MARK: - Button constants

    static let primaryButtonWidth: CGFloat = 120.0
    static let secondaryButtonWidth: CGFloat = 100.0
    static let buttonSpacing: CGFloat = 20.0
    static let buttonHeight: CGFloat = 44.0

    // MARK: - Header constants

    static let headerIconSize: CGFloat = 24.0
    static let headerSpacing: CGFloat = 12.0

    // MARK: - Exercise Overlay constants

    static let cameraPreviewMaxWidth: CGFloat = 800.0
    static let cameraPreviewMaxHeight: CGFloat = 600.0
    static let cameraPreviewCornerRadius: CGFloat = 20.0
    static let repCounterFontSize: CGFloat = 48.0
    static let repCounterCornerRadius: CGFloat = 20.0
    static let statusIndicatorSize: CGFloat = 12.0

    // MARK: - Card constants

    static let cardCornerRadius: CGFloat = 16.0
    static let cardPadding: CGFloat = 16.0
    static let cardSpacing: CGFloat = 14.0

    // MARK: - Session Grid constants

    static let sessionGridSpacing: CGFloat = 14.0
    static let sessionItemCornerRadius: CGFloat = 12.0
    static let sessionItemSize: CGFloat = 80.0

    // MARK: - Settings constants

    static let settingsWidth: CGFloat = 450.0
    static let settingsHeight: CGFloat = 750.0
    static let formSectionCornerRadius: CGFloat = 12.0

    // MARK: - Animation constants

    static let defaultAnimationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)

    // MARK: - Badge/Achievement constants

    static let badgeSize: CGFloat = 52.0
    static let badgeCornerRadius: CGFloat = 24.0
    static let badgeSpacing: CGFloat = 14.0
    static let badgeFrameWidth: CGFloat = 74.0

    // MARK: - Style

    #if os(macOS)
    static let editingBackgroundStyle = WindowBackgroundShapeStyle.windowBackground
    #else
    static let editingBackgroundStyle = Material.ultraThickMaterial
    #endif
}

// MARK: - Color Extensions for Liquid Glass

extension Color {
    /// Primary accent color for work sessions (used sparingly per Liquid Glass guidelines)
    static let workAccent = Color.blue

    /// Primary accent color for break sessions
    static let breakAccent = Color.green

    /// Subtle background for glass containers
    static let glassBackground = Color.gray.opacity(0.1)

    /// Border color for glass containers
    static let glassBorder = Color.white.opacity(0.2)

    /// Text color for secondary information
    static let subtleText = Color.secondary
}
