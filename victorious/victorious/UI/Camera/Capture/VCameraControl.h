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
 *
 *
 */
IB_DESIGNABLE
@interface VCameraControl : UIControl

/**
 *  An enumeration of the available capture modes.
 *  Defaults to "VCameraControlCaptureModeVideo | VCameraControlCaptureModeImage".
 */
@property (nonatomic, assign) VCameraControlCaptureMode captureMode;

@property (nonatomic, readonly) VCameraControlState cameraControlState;

@property (nonatomic, assign) CGFloat recordingProgress;

- (void)setRecordingProgress:(CGFloat)recordingProgress
                    animated:(BOOL)animated;

- (void)restoreCameraControlToDefault;

- (void)showCameraFlashAnimation;

@end
