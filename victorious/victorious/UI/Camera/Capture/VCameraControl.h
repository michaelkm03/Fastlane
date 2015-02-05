//
//  VCameraControl.h
//  cameraButton
//
//  Created by Michael Sena on 1/27/15.
//  Copyright (c) 2015 VIctorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  This extends UIControlEvents. VCameraCaptureControl sends these events to any targets.
 */
enum
{
    VCameraControlEventWantsStillImage = 0x01000000,
    VCameraControlEventStartRecordingVideo = 0x02000000,
    VCameraControlEventEndRecordingVideo = 0x04000000,
};


typedef NS_ENUM(NSInteger, VCameraControlState)
{
    VCameraControlStateDefault, ///< The default state of the control
    VCameraControlStateGrowing, ///< While the control is expanding out in pill form before it has sent any controlEvents
    VCameraControlStateRecording, ///< When recordingProgress is greater than 0.0f
    VCameraControlStateCapturingImage, ///< A growing animation indicating the control is waiting on the hardward
};

typedef NS_OPTIONS(NSInteger, VCameraControlCaptureMode)
{
    VCameraControlCaptureModeVideo = 1 << 0,
    VCameraControlCaptureModeImage = 1 << 1,
};

/**
 *  Converts from a picture to video control based on duration of presses. 
 *  Use: addTarget:action:forControlEvents: with VCameraControlEvents for the corresponding actions associated with this control.
 */
IB_DESIGNABLE
@interface VCameraControl : UIControl

/**
 *  An enumeration of the available capture modes.
 *  Defaults to "VCameraControlCaptureModeVideo | VCameraControlCaptureModeImage".
 */
@property (nonatomic, assign) VCameraControlCaptureMode captureMode;

/**
 *  The current state of the camera control.
 */
@property (nonatomic, readonly) VCameraControlState cameraControlState;

/**
 *  The recording progress corresponding to a percentage completeness. 
 *  Animates the growing of a progress bar.
 */
@property (nonatomic, assign) CGFloat recordingProgress;

/**
 *  Updates a progress bar on the camera control indicating progress through a maximum recording duration.
 */
- (void)setRecordingProgress:(CGFloat)recordingProgress
                    animated:(BOOL)animated;

/**
 *  Clears any recording progress or leftover state from a previous session.
 */
- (void)restoreCameraControlToDefault;

/**
 *  Applies a scale transform indicating the the shutter of a camera.
 */
- (void)showCameraFlashAnimationWithCompletion:(void (^)(void))completion;

@end