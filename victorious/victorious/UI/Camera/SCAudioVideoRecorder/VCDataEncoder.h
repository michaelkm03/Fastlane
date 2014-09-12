//
//  VCDataEncoder
//

@import AVFoundation;

//
// Encoder
//

@class VCDataEncoder;
@class VCAudioVideoRecorder;

@protocol VCDataEncoderDelegate <NSObject>

@optional
- (void) dataEncoder:(VCDataEncoder *)dataEncoder didEncodeFrame:(CMTime)frameTime;
- (void) dataEncoder:(VCDataEncoder *)dataEncoder didFailToInitializeEncoder:(NSError *)error;

@end

@interface VCDataEncoder : NSObject
{
    
}

- (instancetype)initWithAudioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder;
- (void)reset;

// Abstract method
- (AVAssetWriterInput *)createWriterInputForSampleBuffer:(CMSampleBufferRef)sampleBuffer error:(NSError**)error;

@property (assign, nonatomic) BOOL enabled;
@property (strong, nonatomic) AVAssetWriterInput * writerInput;
@property (weak, nonatomic) id<VCDataEncoderDelegate> delegate;
@property (weak, nonatomic, readonly) VCAudioVideoRecorder * audioVideoRecorder;

@end
