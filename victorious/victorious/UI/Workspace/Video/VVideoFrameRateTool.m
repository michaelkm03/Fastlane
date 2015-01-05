//
//  VVideoCompositionController.m
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoFrameRateTool.h"

@interface VVideoFrameRateTool ()

@property (nonatomic, strong, readwrite) NSURL *videoURL;
@property (nonatomic, readwrite) CMTime frameDuration;
@property (nonatomic, readwrite) BOOL muteAudio;

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVMutableComposition *mutableComposition;
@property (nonatomic, strong) AVMutableCompositionTrack *mutableCompositionVideoTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *mutableCompositionAudioTrack;

@end

@implementation VVideoFrameRateTool

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
                                                  NSStringFromSelector(@selector(tracks)),
                                                  NSStringFromSelector(@selector(commonMetadata))]
                              completionHandler:^
         {
             [self buildTracks];
             
             AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.mutableComposition copy]];
             playerItem.videoComposition = [self videoComposition];
             if (self.playerItemReady)
             {
                 self.playerItemReady(playerItem);
             }
         }];
        
        _mutableComposition = [AVMutableComposition composition];
        _mutableCompositionVideoTrack = [_mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
        if (!muteAudio)
        {
            _mutableCompositionAudioTrack = [_mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        }
        
    }
    return self;
}

- (AVAssetExportSession *)makeExportable
{
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:[self.mutableComposition copy]
                                                                            presetName:AVAssetExportPresetHighestQuality];
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

- (void)buildTracks
{
    CMTime videoDuration = self.asset.duration;
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    AVAssetTrack *videoAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [self.mutableCompositionVideoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];

    AVAssetTrack *audioAssetTrack = [[self.asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [self.mutableCompositionAudioTrack insertTimeRange:videoTimeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
}

@end
