//
//  AVComposition+Loop.m
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "AVComposition+Loop.h"

/*
 To create clean loops, multiple AVAssets are added to a composition.
 Playback from one asset to another will be seamless, but eventually there
 will be a slight pause as the composition restarts.  This number determines
 how many assets are added to a composition, and effectively determines
 after how many loops the inevitable pause will show.  Keep it as high as
 performance allows to improve user experience.
 */
static const NSUInteger kCompositionAssetCount = 10;

/*
 When assets are added to the composition, this small bit of time
 is shaved off of the end in order to ensure clean looping.*/
static const Float64 kAssetLoopClipping = 0.08;

@implementation AVComposition (Loop)

+ (AVComposition *)v_loopingCompositionWithAsset:(AVAsset *)asset
{
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    Float64 clippedDuration = CMTimeGetSeconds(asset.duration) - kAssetLoopClipping;
    CMTimeRange editRange = CMTimeRangeMake( kCMTimeZero, CMTimeMakeWithSeconds( clippedDuration, 1) );
    
    for ( NSUInteger i = 0; i < kCompositionAssetCount; i++ )
    {
        [composition insertTimeRange:editRange ofAsset:asset atTime:composition.duration error:nil];
    }
    
    return composition;
}

@end
