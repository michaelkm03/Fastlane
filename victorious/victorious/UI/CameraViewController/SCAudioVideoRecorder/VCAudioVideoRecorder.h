//
//  VCAudioVideoRecorder
//

#import <Foundation/Foundation.h>
#import "VCVideoEncoder.h"
#import "VCAudioEncoder.h"

// photo dictionary keys

extern NSString * const VCAudioVideoRecorderPhotoMetadataKey;
extern NSString * const VCAudioVideoRecorderPhotoJPEGKey;
extern NSString * const VCAudioVideoRecorderPhotoImageKey;
extern NSString * const VCAudioVideoRecorderPhotoThumbnailKey; // 160x120

@class VCAudioVideoRecorder;

//
// VideoRecorderDelegate
//

@protocol VCAudioVideoRecorderDelegate <NSObject>

@optional

- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didRecordVideoFrame:(CMTime)frameTime;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didRecordAudioSample:(CMTime)sampleTime;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder willFinishRecordingAtTime:(CMTime)frameTime;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFinishRecordingAtUrl:(NSURL*)recordedFile
                      error:(NSError*)error;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder willFinalizeAudioMixAtUrl:(NSURL*)recordedFile;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeVideoEncoder:(NSError*)error;
- (void) audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder didFailToInitializeAudioEncoder:(NSError*)error;

// Photo
- (void)audioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error;

@end

//
// AudioVideo Recorder
//

@class VCVideoEncoder;
@class VCAudioEncoder;

@interface VCAudioVideoRecorder : NSObject<VCDataEncoderDelegate>
{
    
}

// The Camera roll only exists on iOS
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (void) prepareRecordingAtCameraRoll:(NSError**)error;
// Photo
- (void) capturePhoto;
#endif

- (NSURL*) prepareRecordingOnTempDir:(NSError**)error;
- (void) prepareRecordingAtUrl:(NSURL*)url error:(NSError**)error;

- (void) record;
- (void) pause;
- (void) cancel;
- (void) stop;

- (BOOL) isPrepared;
- (BOOL) isRecording;

@property (weak, nonatomic) id<VCAudioVideoRecorderDelegate> delegate;

@property (strong, nonatomic, readonly) AVCaptureVideoDataOutput * videoOutput;
@property (strong, nonatomic, readonly) AVCaptureAudioDataOutput * audioOutput;
@property (strong, nonatomic, readonly) AVCaptureStillImageOutput *stillImageOutput;

@property (assign, nonatomic) BOOL enableSound;
@property (assign, nonatomic) BOOL enableVideo;

// The VideoEncoder. Accessing this allow the configuration of the video encoder
@property (strong, nonatomic, readonly) VCVideoEncoder * videoEncoder;

// The AudioEncoder. Accessing this allow the configuration of the audio encoder
@property (strong, nonatomic, readonly) VCAudioEncoder * audioEncoder;

// When the recording is prepared, this getter contains the output file
@property (strong, nonatomic, readonly) NSURL * outputFileUrl;

// If not null, the asset will be played when the record starts, and pause when it pauses.
// When the record ends, the audio mix will be mixed with the playback asset
@property (strong, nonatomic) AVAsset * playbackAsset;
@property (assign, nonatomic) BOOL playPlaybackAssetWhenRecording;

// When the playback asset should start
@property (assign, nonatomic) CMTime playbackStartTime;

// If true, every messages sent to the delegate will be dispatched through the main queue
@property (assign, nonatomic) BOOL dispatchDelegateMessagesOnMainQueue;

// Must be like AVFileType*
@property (copy, nonatomic) NSString * outputFileType;

@property (assign, readonly, nonatomic) CMTime currentRecordingTime;

// The recording will stop when the total recorded time reaches this value
// Default is kCMTimePositiveInfinity
@property (assign, nonatomic) CMTime recordingDurationLimit;

// The rate at which the record should be processed
// The recording will be slower if between 0 and 1 exclusive, faster in more than 1
@property (assign, nonatomic) float recordingRate;

@end
