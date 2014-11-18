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
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput; ///< This property should only be accessed from the sessionQueue

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
        _currentDevice = defaultCaptureDevice();
        _backgroundTaskID = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
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

- (void)startRunningWithCompletion:(void(^)(NSError *))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
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
        
        if (!self.videoOutput)
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
        
        if (!self.audioOutput)
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
            typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                dispatch_sync(self.sessionQueue, ^(void)
                {
                    [strongSelf _stopRunningWithCompletion:nil];
                });
            }
        }];
        
        [self.captureSession startRunning];
        
        if (completion)
        {
            completion(nil);
        }
    });
}

- (void)stopRunningWithCompletion:(void(^)(void))completion
{
    dispatch_async(self.sessionQueue, ^(void)
    {
        [self _stopRunningWithCompletion:completion];
    });
}

- (void)_stopRunningWithCompletion:(void(^)(void))completion
{
    NSLog(@"capture session stop running");
    [self.captureSession stopRunning];
    NSLog(@"end background task");
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
    NSLog(@"call completion");
    if (completion)
    {
        completion();
    }
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

#pragma mark - Notifications

- (void)captureSessionWasInterrupted:(NSNotification *)notification
{
    if (self.videoEncoder.recording)
    {
        self.videoEncoder.recording = NO;
    }
}

@end
