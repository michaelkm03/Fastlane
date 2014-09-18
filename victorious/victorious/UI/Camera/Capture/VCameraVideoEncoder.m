//
//  VCameraVideoEncoder.m
//  victorious
//
//  Created by Josh Hinman on 9/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCameraVideoEncoder.h"

NSString * const VCameraVideoEncoderErrorDomain = @"VCameraVideoEncoderErrorDomain";
const NSInteger VCameraVideoEncoderErrorCode = 100;

@interface VCameraVideoEncoder ()

@property (nonatomic, strong, readwrite) NSURL *fileURL;
@property (nonatomic, readwrite) VCameraCaptureVideoSize videoSize;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic) CMTime lastFrameTimeRecorded;
@property (nonatomic) CMTime frameTimeOffset; ///< the difference between the frame timestamps we're getting from the source, and our output frame timestamps.
@property (nonatomic, getter = isRecordingPaused) BOOL recordingPaused;

@end

@implementation VCameraVideoEncoder
{
    NSURL *_fileURL;
    BOOL _recording;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _encoderQueue = dispatch_queue_create("VCameraVideoEncoder queue", DISPATCH_QUEUE_SERIAL);
        _recording = YES;
        _lastFrameTimeRecorded = kCMTimeInvalid;
        _frameTimeOffset = kCMTimeInvalid;
    }
    return self;
}

+ (instancetype)videoEncoderWithFileURL:(NSURL *)fileURL videoSize:(VCameraCaptureVideoSize)videoSize error:(NSError *__autoreleasing *)error
{
    VCameraVideoEncoder *videoEncoder = [[self alloc] init];
    
    NSError *assetError = nil;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:fileURL fileType:AVFileTypeMPEG4 error:&assetError];
    if (writer)
    {
        videoEncoder.fileURL = [fileURL copy];
        videoEncoder.writer = writer;
        videoEncoder.videoSize = videoSize;
        return videoEncoder;
    }
    else
    {
        if (error && assetError)
        {
            *error = assetError;
        }
        return nil;
    }
}

#pragma mark - Properties

- (BOOL)isRecording
{
    __block BOOL recording;
    dispatch_sync(self.encoderQueue, ^(void)
    {
        recording = _recording;
    });
    return recording;
}

- (void)setRecording:(BOOL)recording
{
    dispatch_async(self.encoderQueue, ^(void)
    {
        [self _setRecording:recording];
    });
}

- (void)_setRecording:(BOOL)recording
{
    if (_recording && !recording)
    {
        self.recordingPaused = YES;
    }
    _recording = recording;
}

#pragma mark -

- (BOOL)writeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo
{
    if (CMSampleBufferDataIsReady(sampleBuffer))
    {
        if (self.writer.status == AVAssetWriterStatusUnknown)
        {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [self.writer startWriting];
            [self.writer startSessionAtSourceTime:startTime];
        }
        if (self.writer.status == AVAssetWriterStatusFailed)
        {
            VLog(@"writer error %@", self.writer.error.localizedDescription);
            return NO;
        }
        if (isVideo)
        {
            if (self.videoInput.readyForMoreMediaData == YES)
            {
                return [self.videoInput appendSampleBuffer:sampleBuffer];
            }
        }
        else
        {
            if (self.audioInput.readyForMoreMediaData)
            {
                return [self.audioInput appendSampleBuffer:sampleBuffer];
            }
        }
    }
    return NO;
}

- (CMSampleBufferRef)copySample:(CMSampleBufferRef)sample andAdjustTimeByOffset:(CMTime)offset
{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo *pInfo = malloc(sizeof(CMSampleTimingInfo)* count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++)
    {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

- (void)finishRecording
{
    dispatch_async(self.encoderQueue, ^(void)
    {
        if (self.writer.status == AVAssetWriterStatusWriting)
        {
            self.recording = NO;
            [self.writer finishWritingWithCompletionHandler:^(void)
            {
                id<VCameraVideoEncoderDelegate> delegate = self.delegate;
                if ([delegate respondsToSelector:@selector(videoEncoderDidFinish:withError:)])
                {
                    if (self.writer.status == AVAssetWriterStatusFailed)
                    {
                        NSError *error = self.writer.error;
                        if (!error)
                        {
                            error = [NSError errorWithDomain:VCameraVideoEncoderErrorDomain
                                                        code:VCameraVideoEncoderErrorCode
                                                    userInfo:@{ NSLocalizedDescriptionKey: @"Unable to finish recording" }];
                        }
                        [delegate videoEncoderDidFinish:self withError:error];
                    }
                    else
                    {
                        [delegate videoEncoderDidFinish:self withError:nil];
                    }
                }
            }];
        }
        else
        {
            id<VCameraVideoEncoderDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(videoEncoderDidFinish:withError:)])
            {
                NSError *error = self.writer.error;
                if (!error)
                {
                    error = [NSError errorWithDomain:VCameraVideoEncoderErrorDomain
                                                code:VCameraVideoEncoderErrorCode
                                            userInfo:@{ NSLocalizedDescriptionKey: @"Tried to finish recording but no recording is happening" }];
                }
                [delegate videoEncoderDidFinish:self withError:error];
            }
        }
    });
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!_recording || !_fileURL) // direct ivar access because calling the property getters would surely deadlock.
    {
        return;
    }
    
    BOOL isVideo = NO;
    if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]])
    {
        isVideo = YES;
    }
    
    if (!self.audioInput && !isVideo)
    {
        NSDictionary *videoSettings = @{ AVVideoCodecKey: AVVideoCodecH264,
                                         AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
                                         AVVideoWidthKey: @(self.videoSize.width),
                                         AVVideoHeightKey: @(self.videoSize.height),
                                    };
        self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        self.videoInput.expectsMediaDataInRealTime = YES;
        [self.writer addInput:self.videoInput];
        
        CMFormatDescriptionRef audioFormat = CMSampleBufferGetFormatDescription(sampleBuffer);
        const AudioStreamBasicDescription *audioStreamDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormat);
        
        NSDictionary *audioSettings = @{ AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                         AVNumberOfChannelsKey: @(audioStreamDescription->mChannelsPerFrame),
                                         AVSampleRateKey: @(audioStreamDescription->mSampleRate),
                                         AVEncoderBitRateKey: @(64000)
                                    };
        self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        self.audioInput.expectsMediaDataInRealTime = YES;
        [self.writer addInput:self.audioInput];
    };
    
    if (self.recordingPaused)
    {
        if (isVideo)
        {
            return;
        }
        self.recordingPaused = NO;

        // Add the amount of time we were paused to the total offset
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        self.frameTimeOffset = CMTimeAdd(self.frameTimeOffset, CMTimeSubtract(timestamp, self.lastFrameTimeRecorded));
    }
    
    if (!CMTIME_IS_VALID(self.frameTimeOffset))
    {
        self.frameTimeOffset = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    }
    
    if (self.videoInput && self.audioInput)
    {
        CMSampleBufferRef adjustedSampleBuffer = [self copySample:sampleBuffer andAdjustTimeByOffset:self.frameTimeOffset];

        BOOL success = [self writeFrame:adjustedSampleBuffer isVideo:isVideo];
        if (!success)
        {
            [self _setRecording:NO];
            id<VCameraVideoEncoderDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(videoEncoder:didEncounterError:)])
            {
                NSError *error = self.writer.error;
                if (!error)
                {
                    error = [NSError errorWithDomain:VCameraVideoEncoderErrorDomain code:VCameraVideoEncoderErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Video frame write failed"}];
                }
                [delegate videoEncoder:self didEncounterError:error];
            }
        }
        
        CFRelease(adjustedSampleBuffer);
        
        if (!success)
        {
            return;
        }
    }
    
    if (!isVideo)
    {
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        if (duration.value > 0)
        {
            timestamp = CMTimeAdd(timestamp, duration);
        }
        self.lastFrameTimeRecorded = timestamp;
        
        id<VCameraVideoEncoderDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(videoEncoder:hasEncodedTotalTime:)])
        {
            [self.delegate videoEncoder:self hasEncodedTotalTime:CMTimeSubtract(self.lastFrameTimeRecorded, self.frameTimeOffset)];
        }
    }
}

@end
