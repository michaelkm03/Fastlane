//
//  VCameraVideoEncoder.h
//  victorious
//
//  Created by Josh Hinman on 9/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraCaptureVideoSize.h"

#import <Foundation/Foundation.h>

@import AVFoundation;

extern NSString * const VCameraVideoEncoderErrorDomain;
extern const NSInteger VCameraVideoEncoderErrorCode;

@class VCameraVideoEncoder;

@protocol VCameraVideoEncoderDelegate <NSObject>
@optional

/**
 Notifies the delegate that a frame has been recorded.
 */
- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder hasEncodedTotalTime:(CMTime)time;

/**
 Notifies the delegate that an error occurred in either recording or writing
 */
- (void)videoEncoder:(VCameraVideoEncoder *)videoEncoder didEncounterError:(NSError *)error;

/**
 Notifies the delegate that recording has finished and all data has been written to disk.
 
 @param error If set, the writing failed
 */
- (void)videoEncoderDidFinish:(VCameraVideoEncoder *)videoEncoder withError:(NSError *)error;

@end

/**
 This class is responsible for taking frames from 
 AVCaptureVideoDataOutput and writing them
 to disk with an AVAssetWriter
 */
@interface VCameraVideoEncoder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

/**
 A serial queue used to synchronize calls to the
 AVCaptureVideoDataOutputSampleBufferDelegate and
 AVCaptureAudioDataOutputSampleBufferDelegate methods
 that this class supports.
 */
@property (nonatomic, readonly) dispatch_queue_t encoderQueue;

/**
 A URL to a file to which the video frames will be written.
 */
@property (nonatomic, readonly) NSURL *fileURL;

/**
 The size of the output video
 */
@property (nonatomic, readonly) VCameraCaptureVideoSize videoSize;

/**
 Set this property to NO to stop writing frames to disk. Defaults to YES
 */
@property (atomic, getter = isRecording) BOOL recording;

/**
 The delegate to be notified when new frames are encoded
 */
@property (atomic, weak) id<VCameraVideoEncoderDelegate> delegate;

/**
 Creates and returns a new instance of this class with
 the given fileURL.
 
 @return nil if the object could not be created
 */
+ (instancetype)videoEncoderWithFileURL:(NSURL *)fileURL videoSize:(VCameraCaptureVideoSize)videoSize error:(NSError *__autoreleasing *)error;

/**
 Sets the recording property to false and finishes writing all frames to disk.
 This method runs asyncronously. When it is done, the delegate will receive
 a videoEncoderDidFinish: message.
 */
- (void)finishRecording;

@end
