//
//  VCameraCaptureController.m
//  victorious
//
//  Created by Josh Hinman on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "AVCaptureConnection+VOrientation.h"
#import "VCameraCaptureController.h"
#import "VCameraVideoEncoder.h"
#import "VConstants.h"

@import AVFoundation;

NSString * const VCameraCaptureControllerErrorDomain = @"VCameraCaptureControllerErrorDomain";
const NSInteger VCameraCaptureControllerErrorCode = 100;

static inline AVCaptureDevice *defaultCaptureDevice()
{
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

@interface VCameraCaptureController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskID;
@property (nonatomic, strong) AVCaptureInput *videoInput; ///< This property should only be accessed from the sessionQueue
@property (nonatomic, strong) AVCaptureInput *audioInput; ///< This property should only be accessed from the sessionQueue
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput; ///< This property should only be accessed from the sessionQueue
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput; ///< This property should only be accessed from the sessionQueue
@property (nonatomic, strong, readwrite) AVCaptureStillImageOutput *imageOutput; ///< This property should only be accessed from the sessionQueue

@end

@implementation VCameraCaptureController
{
    NSArray *_devices;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        _sessionQueue = dispatch_queue_create("VCameraCaptureController setup", DISPATCH_QUEUE_SERIAL);
        _currentDevice = [self defaultDevice];
        _backgroundTaskID = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(captureSessionWasInterrupted:)
                                                     name:AVCaptureSessionWasInterruptedNotification
                                                   object:_captureSession];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (NSArray *)devices
{
    if (!_devices)
    {
        _devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    return _devices;
}

- (AVCaptureDevice *)defaultDevice
{
    return defaultCaptureDevice();
}

- (void)setContext:(VCameraContext)context
{
    _context = context;
    if (context == VCameraContextProfileImage || context == VCameraContextProfileImageRegistration)
    {
        AVCaptureDevice *desiredDevice = [self firstDeviceForPosition:AVCaptureDevicePositionFront];
        if (desiredDevice != nil)
        {
            [self setCurrentDevice:desiredDevice
                    withCompletion:nil];
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-property-ivar"

- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice
{
    [self setCurrentDevice:currentDevice withCompletion:nil];
}

#pragma clang diagnostic pop

- (void)setCurrentDevice:(AVCaptureDevice *)currentDevice withCompletion:(void (^)(NSError *))completion
{
    _currentDevice = currentDevice;
    dispatch_async(self.sessionQueue, ^(void)
    {
        NSError *error = nil;
        if (self.videoInput)
        {
            [self.captureSession removeInput:self.videoInput];
            self.videoInput = nil;
            [self setVideoInputWithDevice:currentDevice error:&error];
        }
        if (completion)
        {
            completion(error);
        }
    });
}

- (void)setSessionPreset:(NSString *)sessionPreset completion:(void (^)(BOOL))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if ([self.captureSession canSetSessionPreset:sessionPreset])
        {
            self.captureSession.sessionPreset = sessionPreset;
            if (completion)
            {
                completion(YES);
            }
        }
        else if (completion)
        {
            completion(NO);
        }
    });
}

- (void)setVideoEncoder:(VCameraVideoEncoder *)videoEncoder
{
    if (videoEncoder == _videoEncoder)
    {
        return;
    }
    
    dispatch_sync(self.sessionQueue, ^(void)
    {
        [self.videoOutput setSampleBufferDelegate:videoEncoder queue:videoEncoder.encoderQueue];
        [self.audioOutput setSampleBufferDelegate:videoEncoder queue:videoEncoder.encoderQueue];
    });

    _videoEncoder = videoEncoder;
}

#pragma mark - Start/Stop

- (void)startRunningWithVideoEnabled:(BOOL)videoEnabled andCompletion:(void (^)(NSError *))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if (self.captureSession.isRunning)
        {
            if (completion != nil)
            {
                completion(nil);
            }
            return;
        }
        
        AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (!self.videoInput &&
            videoAuthorizationStatus != AVAuthorizationStatusDenied &&
            videoAuthorizationStatus != AVAuthorizationStatusRestricted)
        {
            NSError *error = nil;
            if (![self setVideoInputWithDevice:self.currentDevice error:&error])
            {
                VLog(@"Error adding video input: %@", error.localizedDescription);
                if (completion)
                {
                    completion(error);
                }
                return;
            }
        }
        
        AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (!self.audioInput &&
            videoEnabled &&
            audioAuthorizationStatus != AVAuthorizationStatusDenied &&
            audioAuthorizationStatus != AVAuthorizationStatusRestricted)
        {
            NSError *error = nil;
            AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            if (audioInput && [self.captureSession canAddInput:audioInput])
            {
                [self.captureSession addInput:audioInput];
                self.audioInput = audioInput;
            }
            else
            {
                if (completion)
                {
                    if (!error)
                    {
                        error = [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                    code:VCameraCaptureControllerErrorCode
                                                userInfo:@{ NSLocalizedDescriptionKey: @"Unable to add audio input"}];
                    }
                    VLog(@"Error adding audio input: %@", error.localizedDescription);
                    completion(error);
                }
                return;
            }
        }
        
        if (!self.videoOutput && videoEnabled)
        {
            AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
            if ([self.captureSession canAddOutput:videoOutput])
            {
                [self.captureSession addOutput:videoOutput];
                self.videoOutput = videoOutput;
            }
            else
            {
                VLog(@"[AVCaptureSession canAddOutput] returned NO while adding video output");
                if (completion)
                {
                    completion([NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                   code:VCameraCaptureControllerErrorCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to add video output"}]);
                }
                return;
            }
        }
        
        if (!self.audioOutput && videoEnabled)
        {
            AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
            if ([self.captureSession canAddOutput:audioOutput])
            {
                [self.captureSession addOutput:audioOutput];
                self.audioOutput = audioOutput;
            }
            else
            {
                VLog(@"[AVCaptureSession canAddOutput] returned NO while adding audio output");
                if (completion)
                {
                    completion([NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                   code:VCameraCaptureControllerErrorCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to add audio output"}]);
                }
                return;
            }
        }
        
        if (!self.imageOutput)
        {
            AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
            imageOutput.outputSettings = @{ AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey: @(1) }; // full quality, because we're going to decode, filter, and re-encode this image
            if ([self.captureSession canAddOutput:imageOutput])
            {
                [self.captureSession addOutput:imageOutput];
                self.imageOutput = imageOutput;
            }
            else
            {
                VLog(@"[AVCaptureSession canAddOutput] returned NO while adding image output");
                if (completion)
                {
                    completion([NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                   code:VCameraCaptureControllerErrorCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to add image output"}]);
                }
                return;
            }
        }
        
        typeof(self) __weak weakSelf = self;
        self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                dispatch_sync(self.sessionQueue, ^(void)
                {
                    [strongSelf _stopRunningWithCompletion:nil];
                });
            }
        }];
        // Dispatch to main thread to avoid nasty bug where app locks up for a bit
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.captureSession startRunning];
            if (completion != nil)
            {
                completion(nil);
            }
        });
    });
}

- (void)stopRunningWithCompletion:(void(^)(void))completion
{
    VLog(@"");
    dispatch_async(self.sessionQueue, ^(void)
    {
        [self _stopRunningWithCompletion:completion];
    });
}

- (void)_stopRunningWithCompletion:(void(^)(void))completion
{
    // dispatch to main thread to avoid nasty locking bug
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.captureSession stopRunning];
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
        if (completion != nil)
        {
            completion();
        }
    });
}

#pragma mark - Capture

- (void)captureStillWithCompletion:(void (^)(UIImage *, NSError *))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        if (!self.imageOutput)
        {
            if (completion)
            {
                completion(nil, [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                    code:VCameraCaptureControllerErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey: @"Unable to capture image"}]);
            }
            return;
        }
        
        AVCaptureConnection *videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection)
        {
            if (videoConnection.isVideoOrientationSupported)
            {
                [videoConnection setVideoOrientation:[self currentVideoOrientation]];
            }
            
            [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
             {
                 if (error)
                 {
                     if (completion)
                     {
                         completion(nil, error);
                     }
                     return;
                 }
                 
                 if (!imageDataSampleBuffer)
                 {
                     if (completion)
                     {
                         completion(nil, [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                             code:VCameraCaptureControllerErrorCode
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to capture image"}]);
                     }
                     return;
                 }
                 
                 NSData *jpegData = nil;
                 @try
                 {
                     jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                 }
                 @catch (NSException *exception)
                 {
                     if (completion)
                     {
                         completion(nil, [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                             code:VCameraCaptureControllerErrorCode
                                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to capture image"}]);
                     }
                     return;
                 }
                 
                 if (completion)
                 {
                     UIImage *image = [UIImage imageWithData:jpegData];
                     completion(image, nil);
                 }
             }];
        }
        else
        {
            if (completion)
            {
                completion(nil, [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                    code:VCameraCaptureControllerErrorCode
                                                userInfo:@{NSLocalizedDescriptionKey: @"Unable to capture image"}]);
            }
        }
    });
}

- (void)setVideoOrientation:(UIDeviceOrientation)orientation
{
    dispatch_async(self.sessionQueue, ^(void)
                   {
                       AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
                       if (videoConnection)
                       {
                           [videoConnection v_applyDeviceOrientation:orientation];
                       }
                   });
}

#pragma mark -

- (BOOL)setVideoInputWithDevice:(AVCaptureDevice *)device error:(NSError *__autoreleasing*)error
{
    NSError *myError = nil;
    AVCaptureInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&myError];
    if (input && [self.captureSession canAddInput:input])
    {
        [self.captureSession addInput:input];
        self.videoInput = input;
        return YES;
    }

    if (error)
    {
        if (!myError)
        {
            myError = [NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                          code:VCameraCaptureControllerErrorCode
                                      userInfo:@{NSLocalizedDescriptionKey: @"Unable to add input"}];
        }
        *error = myError;
    }
    return NO;
}

#pragma mark - Public Methods

- (AVCaptureDevice *)firstAlternatePositionDevice
{
    AVCaptureDevicePosition currentPostion = self.currentDevice.position;
    AVCaptureDevicePosition desiredPostion = (currentPostion == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    return [self firstDeviceForPosition:desiredPostion];
}

- (AVCaptureDevice *)firstDeviceForPosition:(AVCaptureDevicePosition)position
{
    for (AVCaptureDevice *device in self.devices)
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

- (void)toggleFlashWithCompletion:(void(^)(NSError *error))completion
{
    dispatch_async(self.sessionQueue, ^
    {
        AVCaptureDevice *currentDevice = self.currentDevice;
        AVCaptureFlashMode currentFlashMode = currentDevice.flashMode;
        AVCaptureFlashMode desiredFlashMode = (currentFlashMode == AVCaptureFlashModeOn) ? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
        BOOL canSwitch = [currentDevice isFlashModeSupported:desiredFlashMode];
        NSError *lockError = nil;
        if (canSwitch && [currentDevice lockForConfiguration:&lockError])
        {
            VLog(@"device locked");
            currentDevice.flashMode = desiredFlashMode;
            [currentDevice unlockForConfiguration];
            VLog(@"Flash mode set");
        }
        else
        {
            VLog(@"Lock failure: %@", lockError.localizedDescription);
        }
        if (completion != nil)
        {
            completion(lockError);
        }
    });
}

- (void)focusAtPointOfInterest:(CGPoint)locationInCaptureDeviceCoordinates
                withCompletion:(void(^)(NSError *error))completion
{
    dispatch_async(self.sessionQueue, ^
    {
        AVCaptureDevice *currentDevice = self.currentDevice;
        NSError *lockError = nil;
        if ([currentDevice isFocusPointOfInterestSupported] && [currentDevice lockForConfiguration:&lockError])
        {
            // Lock focus and begin observing subjectArea changes
            [currentDevice setFocusPointOfInterest:locationInCaptureDeviceCoordinates];
            [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [currentDevice setSubjectAreaChangeMonitoringEnabled:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaChanged)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:currentDevice];
            
            [currentDevice unlockForConfiguration];
        }
        if (completion != nil)
        {
            completion(lockError);
        }
    });
}

- (void)restoreContinuousFocusWithCompletion:(void(^)(NSError *error))completion
{
    dispatch_async(self.sessionQueue, ^
    {
        // Unlock focus and move to continuous auto focus
        AVCaptureDevice *currentDevice = self.currentDevice;
        NSError *lockError = nil;
        if ([currentDevice lockForConfiguration:&lockError])
        {
            [currentDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [currentDevice setSubjectAreaChangeMonitoringEnabled:NO];
            [currentDevice unlockForConfiguration];
        }
        if (completion != nil)
        {
            completion(lockError);
        }
    });
}

#pragma mark - Notifications

- (void)captureSessionWasInterrupted:(NSNotification *)notification
{
    if (self.videoEncoder.recording)
    {
        self.videoEncoder.recording = NO;
    }
}

- (void)subjectAreaChanged
{
    [self restoreContinuousFocusWithCompletion:nil];
}

- (AVCaptureVideoOrientation)currentVideoOrientation
{
    AVCaptureVideoOrientation orientation;
    
    switch ([UIDevice currentDevice].orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
}

@end
