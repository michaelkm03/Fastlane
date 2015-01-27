//
//  VVideoFrameRateComposition.m
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoFrameRateComposition.h"

#import <KVOController/FBKVOController.h>

@interface VVideoFrameRateComposition ()

@property (nonatomic, strong, readwrite) NSURL *videoURL;
@property (nonatomic, readwrite) CMTime frameDuration;
@property (nonatomic, readwrite) BOOL muteAudio;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVMutableComposition *mutableComposition;

@end

@implementation VVideoFrameRateComposition

- (instancetype)initWithVideoURL:(NSURL *)videoURL
                   frameDuration:(CMTime)frameDuration
                       muteAudio:(BOOL)muteAudio
{
    self = [super init];
    if (self)
    {
        _videoURL = videoURL;
        _frameDuration = frameDuration;
        _muteAudio = muteAudio;

        _asset = [AVURLAsset URLAssetWithURL:videoURL
                                         options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        
        _mutableComposition = [AVMutableComposition composition];
        
        [_asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration)),
                                                  NSStringFromSelector(@selector(tracks))]
                              completionHandler:^
         {
             [self.mutableComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.asset duration])
                                              ofAsset:self.asset
                                               atTime:kCMTimeZero
                                                error:nil];
             
             AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.mutableComposition copy]];
             playerItem.seekingWaitsForVideoCompositionRendering = YES;
             playerItem.videoComposition = [self videoComposition];
             if (self.muteAudio)
             {
                 playerItem.audioMix = [self mutedAudioMixWithTrack:[self audioTrack]];
             }
             
             if (self.playerItemReady)
             {
                 self.playerItemReady(playerItem);
             }
         }];
    }
    return self;
}

- (AVAssetExportSession *)makeExportable
{
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:[self.mutableComposition copy]
                                                                            presetName:AVAssetExportPresetHighestQuality];
    exportSession.videoComposition = [self videoComposition];

    if (self.muteAudio)
    {
        exportSession.audioMix = [self mutedAudioMixWithTrack:[self audioTrack]];
    }
    
    return exportSession;
}

#pragma mark - Private Methods

- (AVVideoComposition *)videoComposition
{
    AVMutableVideoComposition *videoComposition = [[AVVideoComposition videoCompositionWithPropertiesOfAsset:_asset] mutableCopy];

    videoComposition.frameDuration = self.frameDuration;
    
    // Force render size to be a multiple of 16
    CGSize renderSize = videoComposition.renderSize;
    NSInteger renderWidth = (NSInteger)renderSize.width;
    NSInteger remainderWidth = (renderWidth % 16) ;
    if (remainderWidth != 0)
    {
        renderWidth = renderWidth - remainderWidth;
    }
        renderSize.width = renderWidth;
    NSInteger renderHeight = (NSInteger)renderSize.height;
    NSInteger remainderHeight = (renderHeight % 16) ;
    if (remainderHeight != 0)
    {
        renderHeight = renderHeight - remainderHeight;
    }
    renderSize.height = renderHeight;
    videoComposition.renderSize = renderSize;

    return [videoComposition copy];
}

- (AVAssetTrack *)audioTrack
{
    for (AVAssetTrack *track in self.mutableComposition.tracks)
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
