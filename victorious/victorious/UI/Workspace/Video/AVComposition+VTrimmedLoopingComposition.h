//
//  AVComposition+VTrimmedLoopingComposition.h
//  victorious
//
//  Created by Michael Sena on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVComposition (VTrimmedLoopingComposition)

/**
 *  Factory method for creating a looped trim composition.
 *  @param  asset The asset to use for creating the composition.
 *  @param  trimRange A time range within the total time range of the asset to trim for.
 *  @param  minimumDuration The minimum duration for the created composition. The returned composition will be at least this long.
 *
 *  @warning Asset's duration key should be loaded by the time this method is used otherwise it will block on the calling thread.
 */
+ (AVComposition *)trimmedLoopingCompostionWithAsset:(AVAsset *)asset
                                           trimRange:(CMTimeRange)trimRange
                                     minimumDuration:(CMTime)minimumDuration;

@end
