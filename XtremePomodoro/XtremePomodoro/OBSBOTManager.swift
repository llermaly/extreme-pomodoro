import Foundation
import Combine

/// Swift manager class that wraps the OBSBOT SDK
class OBSBOTManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var deviceName: String?
    @Published var zoomLevel: Double = 1.0
    @Published var isAITrackingEnabled: Bool = false

    private var wrapper: OBSBOTWrapper?

    init() {
        wrapper = OBSBOTWrapper()
    }

    /// Initialize the SDK and start scanning for devices
    func initialize() {
        wrapper?.initialize()

        // Set up device change callback
        wrapper?.setDeviceChangedCallback { [weak self] deviceSN, connected in
            DispatchQueue.main.async {
                self?.isConnected = connected
                if connected {
                    self?.deviceName = deviceSN
                    // Auto-select first device
                    self?.wrapper?.selectDevice(at: 0)
                } else {
                    self?.deviceName = nil
                }
            }
        }

        // Start scanning
        scanForDevices()
    }

    /// Scan for connected OBSBOT devices
    func scanForDevices() {
        wrapper?.scanForDevices()

        // Check if devices are already connected
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if let count = self?.wrapper?.deviceCount(), count > 0 {
                self?.isConnected = true
                self?.deviceName = self?.wrapper?.deviceName(at: 0)
                self?.wrapper?.selectDevice(at: 0)
            }
        }
    }

    /// Move the gimbal to specified angles
    func moveGimbal(yaw: Float, pitch: Float, roll: Float) {
        guard isConnected else { return }
        wrapper?.moveGimbal(withYaw: yaw, pitch: pitch, roll: roll)
    }

    /// Enable or disable AI tracking
    func enableAITracking(_ enable: Bool) {
        guard isConnected else { return }
        wrapper?.enableAITracking(enable)
        isAITrackingEnabled = enable
    }

    /// Set zoom level (1.0 - 2.0, normalized range per SDK docs)
    func setZoom(_ level: Double) {
        guard isConnected else { return }
        let clampedLevel = min(max(level, 1.0), 2.0)
        wrapper?.setZoom(Float(clampedLevel))
        DispatchQueue.main.async {
            self.zoomLevel = clampedLevel
        }
    }

    /// Set field of view
    /// - Parameter fovType: 0=Wide(86°), 1=Medium(78°), 2=Narrow(65°)
    func setFOV(_ fovType: Int) {
        guard isConnected else { return }
        wrapper?.setFov(Int32(fovType))
    }

    /// Move gimbal by speed (for continuous movement)
    func moveGimbalBySpeed(yawSpeed: Float, pitchSpeed: Float) {
        guard isConnected else { return }
        wrapper?.moveGimbalBySpeed(withYawSpeed: yawSpeed, pitchSpeed: pitchSpeed)
    }

    /// Stop gimbal movement
    func stopGimbal() {
        guard isConnected else { return }
        wrapper?.moveGimbalBySpeed(withYawSpeed: 0, pitchSpeed: 0)
    }

    /// Save current position as preset
    func savePreset(id: Int, name: String) {
        guard isConnected else { return }
        wrapper?.savePreset(withId: Int32(id), name: name)
    }

    /// Move to saved preset position
    func moveToPreset(id: Int) {
        guard isConnected else { return }
        wrapper?.moveToPreset(withId: Int32(id))
    }
}
