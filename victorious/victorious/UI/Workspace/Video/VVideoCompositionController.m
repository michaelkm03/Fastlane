//
//  VVideoCompositionController.m
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoCompositionController.h"

@interface VVideoCompositionController ()

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) AVMutableComposition *mutableComposition;
@property (nonatomic, strong) AVMutableCompositionTrack *mutableVideoTrack;

@end

@implementation VVideoCompositionController

- (id)init
{
    self = [super init];
    if (self)
    {
        _mutableComposition = [AVMutableComposition composition];
        _mutableVideoTrack = [_mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                              preferredTrackID:999];
    }
    return self;
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    self.asset = [AVURLAsset URLAssetWithURL:videoURL
                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
}

- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    
    [_asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration)),
                                              NSStringFromSelector(@selector(tracks)),
                                              NSStringFromSelector(@selector(commonMetadata))]
                          completionHandler:^
     {
         CMTime videoDuration = _asset.duration;
         CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
         
         AVAssetTrack *videoTrack = [[_asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
         [self.mutableVideoTrack insertTimeRange:videoTimeRange
                                         ofTrack:videoTrack
                                          atTime:kCMTimeZero
                                           error:nil];
         
         if (self.playerItemRedy)
         {
             self.playerItemRedy([AVPlayerItem playerItemWithAsset:self.mutableComposition]);
         }
     }];
}

@end
