//
//  AVComposition+VMutedAudioMix.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "AVComposition+VMutedAudioMix.h"

@implementation AVComposition (VMutedAudioMix)

- (AVAudioMix *)mutedAudioMix
{
    return [self mutedAudioMixWithTrack:[self audioTrack]];
}

- (AVAssetTrack *)audioTrack
{
    for (AVAssetTrack *track in self.tracks)
    {
        if ([track.mediaType isEqualToString:AVMediaTypeAudio])
        {
            return track;
        }
    }
    return nil;
}

- (AVAudioMix *)mutedAudioMixWithTrack:(AVAssetTrack *)track
{
    if (track == nil)
    {
        return nil;
    }
    
    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [mixParameters setVolume:0.0f
                      atTime:kCMTimeZero];
    AVMutableAudioMix *mix = [AVMutableAudioMix audioMix];
    mix.inputParameters = @[mixParameters];
    return mix;
}

@end
