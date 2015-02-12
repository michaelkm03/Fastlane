//
//  VVideoUtils.h
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

/*
 To create clean loops, multiple AVAssets are added to a composition.
 Playback from one asset to another will be seamless, but eventually there
 will be a slight pause as the composition restarts.  This number determines
 how many assets are added to a composition, and effectively determines
 after how many loops the inevitable pause will show.  Keep it as high as
 performance allows to improve user experience.
 */
extern const NSUInteger kVCompositionAssetCount;

@interface VVideoUtils : NSObject

/**
 Creates an AVComposition that consists of the supplied asset on a loop
 that repeats cleanly, without pauses or other unexpected behavior.
 */
- (AVComposition *)loopingCompositionWithAsset:(AVAsset *)asset;

/**
 Creates an AVPlayerItem on a background thread, using the method `loopingCompoistionWithAsset:`
 if required.  This improves performance when creating compositions with looping videos.
 @param onReady A callback that will be called when complete and supplied with an AVPlayerItem.
 */
- (void)createPlayerItemWithURL:(NSURL *)itemURL loop:(BOOL)loop readyCallback:(void(^)(AVPlayerItem *, CMTime duration))onReady;

@end
