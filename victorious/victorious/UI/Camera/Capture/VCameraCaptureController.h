//
//  VCameraCaptureController.h
//  victorious
//
//  Created by Josh Hinman on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraCaptureVideoSize.h"
#import "VCreationTypes.h"

@class AVCaptureDevice, AVCaptureSession, VCameraVideoEncoder, VWorkspaceFlowController;

extern NSString * const VCameraCaptureControllerErrorDomain;
extern const NSInteger VCameraCaptureControllerErrorCode;

/**
 Creates and manages an AVCapture session
 to grab video and stills from a camera
 and save it to disk.
 */
@interface VCameraCaptureController : NSObject

/**
 The capture session. This property has been exposed so
 it can be used to create preview layers or subscribe
 to notifications. Please don't mutate it directly.
 */
@property (nonatomic, readonly) AVCaptureSession *captureSession;

/**
 An array of available video capture devices.
 */
@property (nonatomic, readonly) NSArray /* AVCaptureDevice */ *devices;

/**
 The default video capture device.
 */
@property (nonatomic, readonly) AVCaptureDevice *defaultDevice;

/**
 The video device that is currently being captured.
 */
@property (nonatomic, strong) AVCaptureDevice *currentDevice;

/**
 The object in this property will be added as a sample buffer
 delegate, so it can begin receiving frames and writing them
 to disk.
 */
@property (nonatomic, strong) VCameraVideoEncoder *videoEncoder;

/**
 Sets the capture session quality level or bitrate
 
 @param completion Will be called on a private queue when the session has been set.
 */
- (void)setSessionPreset:(NSString *)sessionPreset completion:(void(^)(BOOL wasSet))completion;

/**
 Fires up the camera.
 
 @param videoEnabled Determines whether ot not the camera tries to initialize
 audio input and video & audio outputs.
 @param completion Will be called on a private queue when the camera is fully ready.
 */
- (void)startRunningWithVideoEnabled:(BOOL)videoEnabled andCompletion:(void(^)(NSError *))completion;

/**
 Changes the current capture device

 @param completion Will be called on a private queue when the capture device is fully swapped.
 */
- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice withCompletion:(void(^)(NSError *))completion;

/**
 Takes the current device orientation and applies it to the
 video input. It is not necessary to call this prior to 
 taking a still image, but it should be called prior to
 recording any video.
 */
- (void)setVideoOrientation:(UIDeviceOrientation)orientation;

/**
 Captures a still image from the current capture session in JPEG format
 
 @param completion Will be called on a private queue when the image has been captured
 */
- (void)captureStillWithCompletion:(void(^)(UIImage *image, NSError *error))completion;

/**
 Shuts down the camera

 @param completion Will be called on a private queue when the camera is fully shut down.
 */
- (void)stopRunningWithCompletion:(void(^)(void))completion;

/**
 *  Exposed so that consumers can KVO imageOutput's properties for UI fun and profit.
 */
@property (nonatomic, strong, readonly) AVCaptureStillImageOutput *imageOutput;


/*
 *  context of wherein the camera controller is being presented
 */
@property (nonatomic, assign) VCameraContext context;

/**
 *  Returns the first device found for an alternate front/back position.
 */
- (AVCaptureDevice *)firstAlternatePositionDevice;

/**
 *  Toggles the flash of the current capture device from on to off. NEVER goes to auto.
 */
- (void)toggleFlashWithCompletion:(void(^)(NSError *error))completion;

/**
 *  Will focus at the passes in interest point. Begins listenting for 
 *  subjectArea change notifications and will restore continuous autofocus 
 *  if a subjectArea change notification comes through.
 */
- (void)focusAtPointOfInterest:(CGPoint)locationInCaptureDeviceCoordinates
                withCompletion:(void(^)(NSError *error))completion;

/**
 *  Forces the camera to restore continuous focus if it was focusing at a specific focus 
 *  point of interest. Internally this method is called after a subjectArea change 
 *  notification comes through.
 */
- (void)restoreContinuousFocusWithCompletion:(void(^)(NSError *error))completion;

@end
