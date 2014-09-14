//
//  VCameraCaptureController.h
//  victorious
//
//  Created by Josh Hinman on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureDevice, AVCaptureSession;

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
 Sets the capture session quality level or bitrate
 
 @param completion Will be called on a private queue when the session has been set.
 */
- (void)setSessionPreset:(NSString *)sessionPreset completion:(void(^)(BOOL wasSet))completion;

/**
 Fires up the camera.
 
 @param completion Will be called on a private queue when the camera is fully ready.
 */
- (void)startRunningWithCompletion:(void(^)(NSError *))completion;

/**
 Changes the current capture device

 @param completion Will be called on a private queue when the capture device is fully swapped.
 */
- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice withCompletion:(void(^)(NSError *))completion;

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

@end
