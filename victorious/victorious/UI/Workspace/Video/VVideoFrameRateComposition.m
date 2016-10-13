//
//  VVideoFrameRateComposition.m
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoFrameRateComposition.h"

@import KVOController;

NSString * const VVideoFrameRateCompositionErrorDomain = @"VVideoFrameRateCompositionErrorDomain";

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
                                                  NSStringFromSelector(@selector(tracks)),
                                                  NSStringFromSelector(@selector(naturalSize))]
                              completionHandler:^
         {
             if (!self.asset.isReadable)
             {
                 if (self.onPlayerItemReady != nil)
                 {
                     NSError *error = [NSError errorWithDomain:VVideoFrameRateCompositionErrorDomain
                                                          code:0
                                                      userInfo:nil];
                     self.onPlayerItemReady(error, nil);
                 }
                 return;
             }
             
             [self.mutableComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.asset duration])
                                              ofAsset:self.asset
                                               atTime:kCMTimeZero
                                                error:nil];
             
             if (self.muteAudio)
             {
                 [self removeAudioTracksFromComposition:self.mutableComposition];
             }
             
             AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:[self.mutableComposition copy]];
             playerItem.seekingWaitsForVideoCompositionRendering = YES;
             playerItem.videoComposition = [self videoComposition];
             
             if (self.onPlayerItemReady != nil)
             {
                 self.onPlayerItemReady(nil, playerItem);
             }
         }];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
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

- (void)removeAudioTracksFromComposition:(AVMutableComposition *)compositionToMute
{
    NSMutableArray *tracksToRemove = [[NSMutableArray alloc] init];
    [self.mutableComposition.tracks enumerateObjectsUsingBlock:^(AVMutableCompositionTrack *track, NSUInteger idx, BOOL *stop)
     {
         if ([[track mediaType] isEqualToString:AVMediaTypeAudio])
         {
             [tracksToRemove addObject:track];
         }
     }];
    [tracksToRemove enumerateObjectsUsingBlock:^(AVMutableCompositionTrack *track, NSUInteger idx, BOOL *stop)
     {
         [self.mutableComposition removeTrack:track];
     }];
}

@end
