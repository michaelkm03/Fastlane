//
//  AVComposition+Loop.h
//  victorious
//
//  Created by Patrick Lynch on 1/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

@interface AVComposition (Loop)

/**
 Creates an AVComposition that consists of the supplied asset on a loop
 that repeats cleanly, without pauses or other unexpected behavior.
 */
+ (AVComposition *)v_loopingCompositionWithAsset:(AVAsset *)asset;

@end
