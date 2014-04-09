//
//  VCAudioEncoder
//

#import "VCAudioEncoder.h"
#import "VCAudioVideoRecorderInternal.h"

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation VCAudioEncoder {
    
}

@synthesize outputSampleRate;
@synthesize outputChannels;
@synthesize outputBitRate;
@synthesize outputEncodeType;

- (id) initWithAudioVideoRecorder:(VCAudioVideoRecorder *)audioVideoRecorder {
    self = [super initWithAudioVideoRecorder:audioVideoRecorder];
    
    if (self != nil) {
        self.outputSampleRate = 0;
        self.outputChannels = 0;
        self.outputBitRate = 128000;
        self.outputEncodeType = kAudioFormatMPEG4AAC;
    }
    
    return self;
}

- (AVAssetWriterInput*) createWriterInputForSampleBuffer:(CMSampleBufferRef)sampleBuffer error:(NSError **)error {
    
    Float64 sampleRate = self.outputSampleRate;
    int channels = self.outputChannels;
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription * streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    
    if (sampleRate == 0) {
        sampleRate = streamBasicDescription->mSampleRate;
    }
    if (channels == 0) {
        channels = streamBasicDescription->mChannelsPerFrame;
    }
    
    AVAssetWriterInput * audioInput = nil;
    NSDictionary * audioCompressionSetings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [ NSNumber numberWithInt: self.outputEncodeType], AVFormatIDKey,
                                              [ NSNumber numberWithInt: self.outputBitRate ], AVEncoderBitRateKey,
                                              [ NSNumber numberWithFloat: sampleRate], AVSampleRateKey,
                                              [ NSNumber numberWithInt: channels], AVNumberOfChannelsKey,
                                              nil];
    
    if ([self.audioVideoRecorder.assetWriter canApplyOutputSettings:audioCompressionSetings forMediaType:AVMediaTypeAudio])
    {
        audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSetings];
        audioInput.expectsMediaDataInRealTime = YES;
        if (error)
            *error = nil;
    }
    else
    {
        if (error)
            *error = [VCAudioVideoRecorder createError:@"Cannot apply Audio settings"];
    }

    return audioInput;
}

@end
