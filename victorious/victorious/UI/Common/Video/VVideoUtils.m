//
//  VVideoUtils.m
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoUtils.h"
#import "VConstants.h"
#import <KVOController/FBKVOController.h>

const NSUInteger kVCompositionAssetCount = 10;

/*
 When assets are added to the composition, this small bit of time
 is shaved off of the end in order to ensure clean looping.*/
static const int64_t kAssetLoopClippingValue = 8;
static const int64_t kAssetLoopClippingScale = 100;

@interface VVideoUtils()

@property (nonatomic, readwrite) NSUInteger compositionLoopCount;

@end

@implementation VVideoUtils

- (AVComposition *)loopingCompositionWithAsset:(AVAsset *)asset
{
    if (!asset.composable)
    {
        return nil;
    }
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    CMTime clipping = CMTimeMake( kAssetLoopClippingValue, kAssetLoopClippingScale );
    CMTime duration = CMTimeSubtract( asset.duration, clipping );
    CMTimeRange editRange = CMTimeRangeMake( kCMTimeZero, duration );
    
    if ( !CMTIMERANGE_IS_VALID(editRange) )
    {
        editRange = CMTimeRangeMake( kCMTimeZero, kCMTimeZero );
    }
    
    for ( NSUInteger i = 0; i < kVCompositionAssetCount; i++ )
    {
        [composition insertTimeRange:editRange ofAsset:asset atTime:composition.duration error:nil];
    }

    return composition;
}

- (void)createPlayerItemWithURL:(NSURL *)itemURL
                           loop:(BOOL)loop
                  readyCallback:(void(^)(AVPlayerItem *, CMTime originalAssetDuration))onReady
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^void
                   {
                       AVURLAsset *asset = [AVURLAsset URLAssetWithURL:itemURL
                                                               options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(NO)}];
                       [asset loadValuesAsynchronouslyForKeys:@[NSStringFromSelector(@selector(duration)),
                                                                NSStringFromSelector(@selector(tracks))]
                                            completionHandler:^{
                                                __block AVPlayerItem *playerItem = nil;
                                                if ( loop )
                                                {
                                                    AVComposition *composition = [self loopingCompositionWithAsset:asset];
                                                    // Fallback to normal playback if we can't loop.
                                                    playerItem = [AVPlayerItem playerItemWithAsset:composition ?: asset];
                                                }
                                                else
                                                {
                                                    playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                                }
                                                dispatch_async( dispatch_get_main_queue(), ^
                                                               {
                                                                   if ( onReady != nil )
                                                                   {
                                                                       onReady( playerItem, asset.duration );
                                                                   }
                                                               });
                                            }];
                   });
}

@end

