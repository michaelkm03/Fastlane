//
//  VVideoUtils.h
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

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
- (void)createPlayerItemWithURL:(NSURL *)itemURL loop:(BOOL)loop readyCallback:(void(^)(AVPlayerItem *))onReady;

@end
