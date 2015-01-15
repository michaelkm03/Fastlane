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
             
             if (self.playerItemReady)
             {
                 self.playerItemReady(playerItem);
             }
         }];
        
        _mutableComposition = [AVMutableComposition composition];
    }
    return self;
}

- (AVAssetExportSession *)makeExportable
{
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:[self.mutableComposition copy]
                                                                            presetName:AVAssetExportPresetLowQuality];
    exportSession.videoComposition = [self videoComposition];
    
    return exportSession;
}

#pragma mark - Private Methods

- (AVVideoComposition *)videoComposition
{
    AVMutableVideoComposition *videoComposition = [[AVVideoComposition videoCompositionWithPropertiesOfAsset:_asset] mutableCopy];
    
    videoComposition.frameDuration = self.frameDuration;
    
    return [videoComposition copy];
}

@end
