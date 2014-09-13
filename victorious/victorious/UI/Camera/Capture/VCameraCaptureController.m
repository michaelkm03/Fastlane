//
//  VCameraCaptureController.m
//  victorious
//
//  Created by Josh Hinman on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraCaptureController.h"
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
@property (nonatomic, strong) dispatch_queue_t sessionSetupQueue;
@property (nonatomic, strong) AVCaptureInput *currentInput; ///< This property should only be accessed from the sessionSetupQueue
@property (nonatomic, strong) AVCaptureOutput *videoOutput; ///< This property should only be accessed from the sessionSetupQueue
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput; ///< This property should only be accessed from the sessionSetupQueue

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
        _sessionSetupQueue = dispatch_queue_create("VCameraCaptureController setup", DISPATCH_QUEUE_SERIAL);
        _currentDevice = defaultCaptureDevice();
    }
    return self;
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
    dispatch_async(self.sessionSetupQueue, ^(void)
    {
        NSError *error = nil;
        if (self.currentInput)
        {
            [self.captureSession removeInput:self.currentInput];
            self.currentInput = nil;
            [self setCaptureSessionInputWithDevice:currentDevice error:&error];
        }
        if (completion)
        {
            completion(error);
        }
    });
}

- (void)setSessionPreset:(NSString *)sessionPreset completion:(void (^)(BOOL))completion
{
    dispatch_async(self.sessionSetupQueue, ^(void)
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

#pragma mark - Start/Stop

- (void)startRunningWithCompletion:(void(^)(NSError *))completion
{
    dispatch_async(self.sessionSetupQueue, ^(void)
    {
        if (!self.currentInput)
        {
            NSError *error = nil;
            if (![self setCaptureSessionInputWithDevice:self.currentDevice error:&error])
            {
                if (completion)
                {
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
                if (completion)
                {
                    completion([NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                   code:VCameraCaptureControllerErrorCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to add video output"}]);
                }
                return;
            }
        }
        
        if (!self.imageOutput)
        {
            AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
            imageOutput.outputSettings = @{ AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey: @(VConstantJPEGCompressionQuality) };
            if ([self.captureSession canAddOutput:imageOutput])
            {
                [self.captureSession addOutput:imageOutput];
                self.imageOutput = imageOutput;
            }
            else
            {
                if (completion)
                {
                    completion([NSError errorWithDomain:VCameraCaptureControllerErrorDomain
                                                   code:VCameraCaptureControllerErrorCode
                                               userInfo:@{NSLocalizedDescriptionKey: @"Unable to add image output"}]);
                }
                return;
            }
        }
        
        [self.captureSession startRunning];
        
        if (completion)
        {
            completion(nil);
        }
    });
}

- (void)captureStillWithCompletion:(void (^)(NSURL *, NSError *))completion
{
    dispatch_async(self.sessionSetupQueue, ^(void)
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
            [self applyDeviceOrientation:[[UIDevice currentDevice] orientation] toConnection:videoConnection];
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
                    NSURL *fileURL = [self temporaryFileURL];
                    [jpegData writeToURL:fileURL atomically:YES];
                    completion(fileURL, nil);
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

- (void)applyDeviceOrientation:(UIDeviceOrientation)orientation toConnection:(AVCaptureConnection *)connection
{
    if (connection.supportsVideoOrientation)
    {
        switch (orientation)
        {
            case UIDeviceOrientationUnknown:
                [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIDeviceOrientationPortrait:
                [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                break;
            case UIDeviceOrientationLandscapeLeft:
                [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                break;
            case UIDeviceOrientationLandscapeRight:
                [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                break;
            case UIDeviceOrientationFaceUp:
            case UIDeviceOrientationFaceDown:
                [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                break;
        }
    }
}

- (NSURL *)temporaryFileURL
{
    NSUUID *uuid = [NSUUID UUID];
    NSString *tempFilename = [[uuid UUIDString] stringByAppendingPathExtension:VConstantMediaExtensionJPG];
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempFilename]];
}

- (void)stopRunningWithCompletion:(void(^)(void))completion
{
    dispatch_async(self.sessionSetupQueue, ^(void)
    {
        [self.captureSession stopRunning];
        if (completion)
        {
            completion();
        }
    });
}

#pragma mark -

- (BOOL)setCaptureSessionInputWithDevice:(AVCaptureDevice *)device error:(NSError *__autoreleasing*)error
{
    NSError *myError = nil;
    AVCaptureInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&myError];
    if (input && [self.captureSession canAddInput:input])
    {
        [self.captureSession addInput:input];
        self.currentInput = input;
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

@end
