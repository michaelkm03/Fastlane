//
//  VCCamera
//

#import <Foundation/Foundation.h>
#import "VCAudioVideoRecorder.h"

typedef NS_ENUM(NSInteger, VCFlashMode)
{
    VCFlashModeOff  = AVCaptureFlashModeOff,
    VCFlashModeOn   = AVCaptureFlashModeOn,
    VCFlashModeAuto = AVCaptureFlashModeAuto,
    VCFlashModeLight
};

typedef NS_ENUM(NSInteger, VCCameraDevice)
{
    VCCameraDeviceBack = AVCaptureDevicePositionBack,
    VCCameraDeviceFront = AVCaptureDevicePositionFront
};

typedef NS_ENUM(NSInteger, VCCameraFocusMode)
{
    VCCameraFocusModeLocked = AVCaptureFocusModeLocked,
    VCCameraFocusModeAutoFocus = AVCaptureFocusModeAutoFocus,
    VCCameraFocusModeContinuousAutoFocus = AVCaptureFocusModeContinuousAutoFocus
};

@class VCCamera;
@protocol VCCameraDelegate <VCAudioVideoRecorderDelegate>

@optional

// Photo
// These methods are commonly used to show a custom animation
- (void)cameraWillCapturePhoto:(VCCamera *)camera;
- (void)cameraDidCapturePhoto:(VCCamera *)camera;
- (void)camera:(VCCamera *)camera cleanApertureDidChange:(CGRect)cleanAperture;

// Focus
- (void)cameraWillStartFocus:(VCCamera *)camera;
- (void)cameraDidStartFocus:(VCCamera *)camera;
- (void)cameraDidStopFocus:(VCCamera *)camera;
- (void)camera:(VCCamera *)camera didFailFocus:(NSError *)error;

// FocusMode
- (void)cameraUpdateFocusMode:(NSString *)focusModeString;

// Session
// These methods are commonly used to show an open/close session animation
- (void)cameraSessionWillStart:(VCCamera *)camera;
- (void)cameraSessionDidStart:(VCCamera *)camera;
- (void)cameraSessionWillStop:(VCCamera *)camera;
- (void)cameraSessionDidStop:(VCCamera *)camera;

@end

typedef enum
{
    VCVideoGravityResize,
    VCVideoGravityResizeAspectFill,
    VCVideoGravityResizeAspect
} VCCameraPreviewVideoGravity;

@interface VCCamera : VCAudioVideoRecorder
{
    
}

+ (VCCamera *) camera;
- (instancetype)initWithSessionPreset:(NSString *)sessionPreset;
- (void)initialize:(void(^)(NSError *audioError, NSError *videoError))completionHandler;
- (BOOL)isReady;

@property (strong, nonatomic, readonly) AVCaptureSession * session;
@property (weak, nonatomic) id<VCCameraDelegate> delegate;
@property (copy, nonatomic) NSString * sessionPreset;
@property (assign, nonatomic) VCCameraPreviewVideoGravity previewVideoGravity;
@property (assign, nonatomic) AVCaptureVideoOrientation videoOrientation;
@property (readonly) AVCaptureDevice * currentDevice;


@property (nonatomic) VCFlashMode flashMode;
@property (nonatomic) VCCameraDevice cameraDevice;

// Focus
@property (nonatomic, readonly, getter = focusSupported) BOOL isFocusSupported;
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)autoFocusAtPoint:(CGPoint)point;
// Switch to continuous auto focus mode at the specified point
- (void)continuousFocusAtPoint:(CGPoint)point;

// Session
- (void)startRunningSession;
- (void)stopRunningSession;

// Switch between back and front camera
- (void) switchCamera;

- (BOOL)isFrameRateSupported:(NSInteger)frameRate;

// Offer a way to configure multiple things at once
// You can call multiple beginSessionConfiguration recursively
// Each call of beginSessionConfiguration must be followed by a commitSessionConfiguration at some point
// Only the latest commitSessionConfiguration will in fact actually commit the configuration
- (void)beginSessionConfiguration;
- (void)commitSessionConfiguration;

// preview
@property (nonatomic, strong) UIView * previewView;

@property (nonatomic, readonly) CGRect cleanAperture;
@property (readonly, nonatomic) VCCameraFocusMode focusMode;

@end
