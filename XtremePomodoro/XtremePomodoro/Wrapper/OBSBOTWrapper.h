//
//  OBSBOTWrapper.h
//  XtremePomodoro
//
//  Objective-C wrapper for the OBSBOT C++ SDK
//  This allows Swift to interact with the C++ library
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Callback type for device connection changes
typedef void (^OBSBOTDeviceChangedCallback)(NSString *deviceSN, BOOL connected);

/// Objective-C wrapper for OBSBOT SDK
@interface OBSBOTWrapper : NSObject

/// Initialize the SDK
- (void)initialize;

/// Scan for connected OBSBOT devices
- (void)scanForDevices;

/// Get number of connected devices
- (NSInteger)deviceCount;

/// Get device name at index
- (nullable NSString *)deviceNameAtIndex:(NSInteger)index;

/// Select device at index for control
- (BOOL)selectDeviceAtIndex:(NSInteger)index;

/// Set callback for device connection changes
- (void)setDeviceChangedCallback:(OBSBOTDeviceChangedCallback)callback;

#pragma mark - Gimbal Control

/// Move gimbal to absolute angles (degrees)
/// @param yaw Horizontal rotation (-110 to 110)
/// @param pitch Vertical rotation (-45 to 45)
/// @param roll Roll angle
- (void)moveGimbalWithYaw:(float)yaw pitch:(float)pitch roll:(float)roll;

/// Move gimbal by speed (for continuous movement)
/// @param yawSpeed Horizontal speed (-90 to 90)
/// @param pitchSpeed Vertical speed (-90 to 90)
- (void)moveGimbalBySpeedWithYawSpeed:(float)yawSpeed pitchSpeed:(float)pitchSpeed;

#pragma mark - AI Tracking

/// Enable or disable AI human tracking
- (void)enableAITracking:(BOOL)enable;

#pragma mark - Camera Control

/// Set zoom level (1.0 to 4.0)
- (void)setZoom:(float)level;

/// Set field of view
/// @param fovType 0=Wide(86°), 1=Medium(78°), 2=Narrow(65°)
- (void)setFov:(int32_t)fovType;

#pragma mark - Presets

/// Save current position as preset
- (void)savePresetWithId:(int32_t)presetId name:(NSString *)name;

/// Move to preset position
- (void)moveToPresetWithId:(int32_t)presetId;

@end

NS_ASSUME_NONNULL_END
