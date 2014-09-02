//
//  VCAudioVideoRecorder
//

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <AssetsLibrary/AssetsLibrary.h>
#endif
#import "VCAudioVideoRecorderInternal.h"

#import "VCAudioTools.h"

#import "VConstants.h"

@import ImageIO;

// photo dictionary key definitions

NSString * const VCAudioVideoRecorderPhotoMetadataKey = @"VCAudioVideoRecorderPhotoMetadataKey";
NSString * const VCAudioVideoRecorderPhotoJPEGKey = @"VCAudioVideoRecorderPhotoJPEGKey";
NSString * const VCAudioVideoRecorderPhotoImageKey = @"VCAudioVideoRecorderPhotoImageKey";
NSString * const VCAudioVideoRecorderPhotoThumbnailKey = @"VCAudioVideoRecorderPhotoThumbnailKey";

//static CGFloat const VCAudioVideoRecorderThumbnailWidth = 160.0f;

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface VCAudioVideoRecorder()
{
	BOOL recording;
	BOOL shouldWriteToCameraRoll;
	BOOL audioEncoderReady;
	BOOL videoEncoderReady;
    float _recordingRate;
	CMTime _playbackStartTime;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	UIBackgroundTaskIdentifier _backgroundIdentifier;
#endif
}

@property (strong, nonatomic) AVCaptureVideoDataOutput * videoOutput;
@property (strong, nonatomic) AVCaptureAudioDataOutput * audioOutput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) VCVideoEncoder * videoEncoder;
@property (strong, nonatomic) VCAudioEncoder * audioEncoder;
@property (strong, nonatomic) NSURL * outputFileUrl;
@property (strong, nonatomic) AVPlayer * playbackPlayer;
@property (assign, nonatomic) CMTime currentRecordingTime;

@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation VCAudioVideoRecorder

@synthesize delegate;
@synthesize videoOutput;
@synthesize audioOutput;
@synthesize outputFileUrl;
@synthesize audioEncoder;
@synthesize videoEncoder;
@synthesize dispatchDelegateMessagesOnMainQueue;
@synthesize outputFileType;
@synthesize playbackAsset;
@synthesize playbackPlayer;
@synthesize recordingDurationLimit;

- (instancetype)init
{
	self = [super init];
	
	if (self)
    {
        _recordingRate = 1.0;
		self.outputFileType = AVFileTypeMPEG4;
		self.recordingDurationLimit = kCMTimePositiveInfinity;
		
		self.dispatch_queue = dispatch_queue_create("VCVideoRecorder", nil);
		
		audioEncoderReady = NO;
		videoEncoderReady = NO;
		self.audioEncoder = [[VCAudioEncoder alloc] initWithAudioVideoRecorder:self];
		self.videoEncoder = [[VCVideoEncoder alloc] initWithAudioVideoRecorder:self];
		self.audioEncoder.delegate = self;
		self.videoEncoder.delegate = self;
		recording = NO;
		
		self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
		[self.videoOutput setSampleBufferDelegate:self.videoEncoder queue:self.dispatch_queue];
		
		self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
		[self.audioOutput setSampleBufferDelegate:self.audioEncoder queue:self.dispatch_queue];
        
        // setup photo settings
        NSDictionary *photoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       AVVideoCodecJPEG, AVVideoCodecKey,
                                       nil];
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [self.stillImageOutput setOutputSettings:photoSettings];
		
		self.lastFrameTimeBeforePause = CMTimeMake(0, 1);
		self.dispatchDelegateMessagesOnMainQueue = YES;
		self.enableSound = YES;
		self.enableVideo = YES;
        self.playPlaybackAssetWhenRecording = YES;
		_playbackStartTime = kCMTimeZero;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
		_backgroundIdentifier = UIBackgroundTaskInvalid;
#endif
	}
	return self;
}

- (void)dealloc
{
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.stillImageOutput = nil;
    
    self.videoEncoder = nil;
    self.audioEncoder = nil;
    
    self.outputFileUrl = nil;
    
    self.playbackAsset = nil;
    
    self.outputFileType = nil;
    
    self.dispatch_queue = nil;
    
    self.assetWriter = nil;
}

// Hack to force ARC to not release an object in a code block
- (void)pleaseDontReleaseObject:(id)object
{
	
}

//
// Video Recorder methods
//

- (void)prepareRecordingAtCameraRoll:(NSError **)error
{
	[self prepareRecordingOnTempDir:error];
	shouldWriteToCameraRoll = YES;
}

- (NSURL*)prepareRecordingOnTempDir:(NSError **)error
{
	long timeInterval =  (long)[[NSDate date] timeIntervalSince1970];
    NSString* fileName = [NSString stringWithFormat:@"%ld%@", timeInterval, @"VCVideo.mp4"];
	NSURL * fileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    
	NSError * recordError = nil;
	[self prepareRecordingAtUrl:fileUrl error:&recordError];
    
	if (recordError != nil) {
		if (error != nil) {
			*error = recordError;
		}
		[self removeFile:fileUrl];
		fileUrl = nil;
        
	}
    
	return fileUrl;
}

- (void)prepareRecordingAtUrl:(NSURL *)fileUrl error:(NSError **)error
{
	if (fileUrl == nil)
    {
		[NSException raise:@"Invalid argument" format:@"FileUrl must be not nil"];
    }

	dispatch_sync(self.dispatch_queue, ^{
		[self resetInternal];
		[self startBackgroundTask];
		
		shouldWriteToCameraRoll = NO;
		self.currentTimeOffset = CMTimeMake(0, 1);
		
		NSError * assetError;
		
		AVAssetWriter * writer = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:self.outputFileType error:&assetError];
		
		if (assetError == nil)
        {
			self.assetWriter = writer;
			self.outputFileUrl = fileUrl;
			
			if (error != nil)
            {
				*error = nil;
			}
		}
        else
        {
			if (error != nil)
            {
				*error = assetError;
			}
		}
	});
    
	if (self.playbackAsset != nil)
    {
		self.playbackPlayer = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.playbackAsset]];
		[self.playbackPlayer seekToTime:self.playbackStartTime];
	}
}

- (void)removeFile:(NSURL *)fileURL {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filePath = [fileURL path];
	if ([fileManager fileExistsAtPath:filePath])
    {
		NSError *error;
		[fileManager removeItemAtPath:filePath error:&error];
	}
}

- (void)finalizeAudioMixForUrl:(NSURL*)fileUrl withCompletionBlock:(void(^)(NSError *))completionBlock
{
	NSError * error = nil;
	if (self.playbackAsset != nil)
    {
        if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:willFinalizeAudioMixAtUrl:)])
        {
            [self.delegate audioVideoRecorder:self willFinalizeAudioMixAtUrl:fileUrl];
        }
        
		// Move the file to a temporary one
		NSURL * oldUrl = [[fileUrl URLByDeletingPathExtension] URLByAppendingPathExtension:@"old.mp4"];
		[[NSFileManager defaultManager] moveItemAtURL:fileUrl toURL:oldUrl error:&error];
		
		if (error == nil)
        {
			[VCAudioTools mixAudio:self.playbackAsset startTime:self.playbackStartTime withVideo:oldUrl affineTransform:self.videoEncoder.outputAffineTransform toUrl:fileUrl outputFileType:self.outputFileType withMaxDuration:self.recordingDurationLimit withCompletionBlock:^(NSError * error2) {
				if (error2 == nil)
                {
					[self removeFile:oldUrl];
				}
				
				completionBlock(error2);
			}];
		}
        else
        {
			completionBlock(error);
		}
	}
    else
    {
		completionBlock(error);
	}
}

- (void)assetWriterFinished:(NSURL*)fileUrl
{
	self.assetWriter = nil;
	self.outputFileUrl = nil;
	[self.audioEncoder reset];
	[self.videoEncoder reset];
	
	[self finalizeAudioMixForUrl:fileUrl withCompletionBlock:^(NSError * error)
     {
		if (shouldWriteToCameraRoll && error == nil)
        {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
			ALAssetsLibrary * library = [[ALAssetsLibrary alloc] init];
			[library writeVideoAtPathToSavedPhotosAlbum:fileUrl completionBlock:^(NSURL *assetUrl, NSError * error)
             {
				[self pleaseDontReleaseObject:library];
				
				if (error != nil)
                {
					NSLog(@"Error: %@", error);
				}
				
				[self removeFile:fileUrl];
				
				[self notifyRecordFinishedAtUrl:assetUrl withError:error];
			}];
#endif
		}
        else
        {
			[self notifyRecordFinishedAtUrl:fileUrl withError:error];
		}
	}];
}

- (void)finishWriter:(NSURL*)fileUrl
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [self.assetWriter finishWritingWithCompletionHandler:^ {
        dispatch_async(self.dispatch_queue, ^{
            [self stopInternal];
        });
    }];
#else
    [self.assetWriter finishWriting];
	[self stopInternal];
#endif
}

- (void)notifyRecordFinishedAtUrl:(NSURL*)url withError:(NSError*)error
{
	[self dispatchBlockOnAskedQueue:^{
		if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:didFinishRecordingAtUrl:error:)]) {
			[self.delegate audioVideoRecorder:self didFinishRecordingAtUrl:url error:error];
		}
	}];
}

- (void) startBackgroundTask
{
	[self stopBackgroundTask];
	
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	_backgroundIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[self stopBackgroundTask];
	}];
#endif
}

- (void) stopBackgroundTask
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	if (_backgroundIdentifier != UIBackgroundTaskInvalid)
    {
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundIdentifier];
		_backgroundIdentifier = UIBackgroundTaskInvalid;
	}
#endif
}

// Photo

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (UIImage *)_uiimageFromJPEGData:(NSData *)jpegData
{
	return [UIImage imageWithData:jpegData];
}

- (void) capturePhoto
{
    if (self.stillImageOutput)
    {
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([connection isVideoOrientationSupported])
        {
            switch ([UIDevice currentDevice].orientation)
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
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:
         ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
         {
             
             if (!imageDataSampleBuffer)
             {
                 NSLog(@"failed to obtain image data sample buffer");
                 // TODO: return delegate error
                 return;
             }
             
             if (error)
             {
				 [self dispatchBlockOnAskedQueue:^{
					 if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:capturedPhoto:error:)])
                     {
						 [self.delegate audioVideoRecorder:self capturedPhoto:nil error:error];
					 }
				 }];
				 return;
             }
             
             NSMutableDictionary *photoDict = [[NSMutableDictionary alloc] init];
             NSDictionary *metadata = nil;
             
             // add photo metadata (ie EXIF: Aperture, Brightness, Exposure, FocalLength, etc)
             metadata = (__bridge NSDictionary *)CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
             if (metadata)
             {
                 [photoDict setObject:metadata forKey:VCAudioVideoRecorderPhotoMetadataKey];
                 CFRelease((__bridge CFTypeRef)(metadata));
             }
             else
             {
                 NSLog(@"failed to generate metadata for photo");
             }
             
             // add JPEG and image data
             NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             if (jpegData)
             {
                 // add JPEG
                 [photoDict setObject:jpegData forKey:VCAudioVideoRecorderPhotoJPEGKey];
                 
                 // add image
                 UIImage *image = [self _uiimageFromJPEGData:jpegData];
                 if (image)
                 {
                     [photoDict setObject:image forKey:VCAudioVideoRecorderPhotoImageKey];
                 }
                 else
                 {
                     NSLog(@"failed to create image from JPEG");
                     // TODO: return delegate on error
                 }
             }
             else
             {
                 NSLog(@"failed to create jpeg still image data");
                 // TODO: return delegate on error
             }
             
			 [self dispatchBlockOnAskedQueue:^{
				 if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:capturedPhoto:error:)])
                 {
					 [self.delegate audioVideoRecorder:self capturedPhoto:photoDict error:error];
				 }
			 }];
         }];
    }
}
#endif

- (void)stop
{
	[self pause];
	[self stopBackgroundTask];
	
	if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:willFinishRecordingAtTime:)])
    {
		[self.delegate audioVideoRecorder:self willFinishRecordingAtTime:self.currentRecordingTime];
	}
    
	dispatch_async(self.dispatch_queue, ^{
		if (self.assetWriter == nil)
        {
			[self notifyRecordFinishedAtUrl:nil withError:[VCAudioVideoRecorder createError:@"Recording must be started before calling stopRecording"]];
		}
        else
        {
			[self stopInternal];
		}
    });
}

- (void)stopInternal
{
	NSURL * fileUrl = self.outputFileUrl;
	NSError * error = self.assetWriter.error;
	
	switch (self.assetWriter.status)
    {
		case AVAssetWriterStatusWriting:
			[self finishWriter:fileUrl];
			break;
		case AVAssetWriterStatusCompleted:
			[self assetWriterFinished:fileUrl];
			break;
		case AVAssetWriterStatusFailed:
			[self resetInternal];
			[self notifyRecordFinishedAtUrl:nil withError:error];
			break;
		case AVAssetWriterStatusCancelled:
			[self resetInternal];
			[self notifyRecordFinishedAtUrl:nil withError:[VCAudioVideoRecorder createError:@"Writer cancelled"]];
			break;
		case AVAssetWriterStatusUnknown:
			[self resetInternal];
			[self notifyRecordFinishedAtUrl:nil withError:[VCAudioVideoRecorder createError:@"Writer status unknown"]];
			break;
	}
}

- (void)pause
{
	[self.playbackPlayer pause];
	recording = NO;
	self.lastFrameTimeBeforePause = CMTimeMake(1, 24);
}

- (void)record
{
	if (![self isPrepared])
    {
		[NSException raise:@"Recording not previously started" format:@"Recording should be started using startRecording before trying to resume it"];
    }
	
    if (self.playPlaybackAssetWhenRecording)
    {
        self.playbackPlayer.rate = self.recordingRate;
    }
	dispatch_async(self.dispatch_queue, ^ {
        AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if ([connection isVideoOrientationSupported])
        {
            switch ([UIDevice currentDevice].orientation)
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
        
		self.shouldComputeOffset = YES;
		recording = YES;
    });
}

- (void)cancel
{
	dispatch_sync(self.dispatch_queue, ^{
		[self resetInternal];
    });
}

- (void)resetInternal
{
	[self stopBackgroundTask];
	AVAssetWriter * writer = self.assetWriter;
	NSURL * fileUrl = self.outputFileUrl;
	
	audioEncoderReady = NO;
	videoEncoderReady = NO;
	
	self.outputFileUrl = nil;
	self.assetWriter = nil;
	self.playbackPlayer = nil;

	recording = NO;
    
	[self.audioEncoder reset];
	[self.videoEncoder reset];
    
	if (writer != nil)
    {
		if (writer.status == AVAssetWriterStatusWriting)
        {
			[writer cancelWriting];
		}
        
		if (fileUrl != nil)
        {
			[self removeFile:fileUrl];
		}
	}
}

//
// DataEncoder Delegate implementation
//

- (void)dataEncoder:(VCDataEncoder *)dataEncoder didEncodeFrame:(CMTime)frameTime
{
    [self dispatchBlockOnAskedQueue:^ {
		self.currentRecordingTime = frameTime;
		
        if (dataEncoder == self.audioEncoder)
        {
            if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:didRecordAudioSample:)])
            {
                [self.delegate audioVideoRecorder:self didRecordAudioSample:frameTime];
            }
        }
        else if (dataEncoder == self.videoEncoder)
        {
            if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:didRecordVideoFrame:)])
            {
                [self.delegate audioVideoRecorder:self didRecordVideoFrame:frameTime];
            }
        }
        
		if (CMTIME_COMPARE_INLINE(frameTime, >=, self.recordingDurationLimit))
        {
			[self stop];
		}
    }];
}

- (void)dataEncoder:(VCDataEncoder *)dataEncoder didFailToInitializeEncoder:(NSError *)error
{
    [self dispatchBlockOnAskedQueue: ^ {
        if (dataEncoder == self.audioEncoder)
        {
            if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:didFailToInitializeAudioEncoder:)])
            {
                [self.delegate audioVideoRecorder:self didFailToInitializeAudioEncoder:error];
            }
        } else if (dataEncoder == self.videoEncoder)
        {
            if ([self.delegate respondsToSelector:@selector(audioVideoRecorder:didFailToInitializeVideoEncoder:)])
            {
                [self.delegate audioVideoRecorder:self didFailToInitializeVideoEncoder:error];
            }
        }
    }];
}

//
// Misc methods
//

- (void)dispatchBlockOnAskedQueue:(void(^)())block
{
	if (self.dispatchDelegateMessagesOnMainQueue)
    {
		dispatch_async(dispatch_get_main_queue(), block);
	}
    else
    {
		block();
	}
}

+ (NSError*)createError:(NSString*)name
{
	return [NSError errorWithDomain:kVictoriousErrorDomain code:500 userInfo:[NSDictionary dictionaryWithObject:name forKey:NSLocalizedDescriptionKey]];
}

- (void)prepareWriterAtSourceTime:(CMTime)sourceTime fromEncoder:(VCDataEncoder*)encoder
{
    // Set an encoder as ready if it's the caller or if it's not enabled
    audioEncoderReady |= (encoder == self.audioEncoder) | !self.audioEncoder.enabled;
    videoEncoderReady |= (encoder == self.videoEncoder) | !self.videoEncoder.enabled;
    
    // We only start the writing when both encoder are ready
    if (audioEncoderReady && videoEncoderReady)
    {
        if (self.assetWriter.status == AVAssetWriterStatusUnknown)
        {
            if ([self.assetWriter startWriting])
            {
                [self.assetWriter startSessionAtSourceTime:sourceTime];
            }
            self.startedTime = sourceTime;
        }
    }
}

//
// Getters/Setters
//

- (BOOL)isPrepared
{
    return self.assetWriter != nil;
}

- (BOOL)isRecording
{
    return recording;
}

- (void)setEnableSound:(BOOL)enableSound
{
    self.audioEncoder.enabled = enableSound;
}

- (BOOL)enableSound
{
    return self.audioEncoder.enabled;
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    self.videoEncoder.enabled = enableVideo;
}

- (BOOL)enableVideo
{
    return self.videoEncoder.enabled;
}

- (CMTime)playbackStartTime
{
	return _playbackStartTime;
}

- (void)setPlaybackStartTime:(CMTime)startTime
{
	_playbackStartTime = startTime;
	[self.playbackPlayer seekToTime:startTime];
}

- (float)recordingRate
{
    return _recordingRate;
}

- (void)setRecordingRate:(float)recordingRate
{
    _recordingRate = recordingRate;
}

@end
