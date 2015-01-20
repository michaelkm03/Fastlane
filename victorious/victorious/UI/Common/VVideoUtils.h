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

- (void)createPlayerItemWithURL:(NSURL *)itemURL loop:(BOOL)loop readyCallback:(void(^)(AVPlayerItem *))onReady;

@end
