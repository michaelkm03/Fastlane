//
//  VVideoUtils.m
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoUtils.h"
#import "VConstants.h"

const NSUInteger kVCompositionAssetCount = 10;

/*
 When assets are added to the composition, this small bit of time
 is shaved off of the end in order to ensure clean looping.*/
static const Float64 kAssetLoopClipping = 0.08;

@interface VVideoUtils()

@property (nonatomic, readwrite) NSUInteger compositionLoopCount;

@end

@implementation VVideoUtils

- (AVComposition *)loopingCompositionWithAsset:(AVAsset *)asset
{
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    Float64 clippedDuration = CMTimeGetSeconds(asset.duration) - kAssetLoopClipping;
    CMTimeRange editRange = CMTimeRangeMake( kCMTimeZero, CMTimeMakeWithSeconds( clippedDuration, 1 ) );
    
    for ( NSUInteger i = 0; i < kVCompositionAssetCount; i++ )
    {
        [composition insertTimeRange:editRange ofAsset:asset atTime:composition.duration error:nil];
    }
    
    return composition;
}

- (void)createPlayerItemWithURL:(NSURL *)itemURL loop:(BOOL)loop readyCallback:(void(^)(AVPlayerItem *, CMTime duration))onReady
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 ), ^void
                   {
                       AVURLAsset *asset = [AVURLAsset URLAssetWithURL:itemURL options:nil];
                       __block AVPlayerItem *playerItem = nil;
                       if ( loop )
                       {
                           AVComposition *composition = [self loopingCompositionWithAsset:asset];
                           playerItem = [AVPlayerItem playerItemWithAsset:composition];
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
                   });
}

@end

