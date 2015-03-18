//
//  AVComposition+VTrimmedLoopingComposition.m
//  victorious
//
//  Created by Michael Sena on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "AVComposition+VTrimmedLoopingComposition.h"

@implementation AVComposition (VTrimmedLoopingComposition)

+ (AVComposition *)trimmedLoopingCompostionWithAsset:(AVAsset *)asset
                                           trimRange:(CMTimeRange)trimRange
                                     minimumDuration:(CMTime)minimumDuration
{
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    CMTimeRange assetRange = kCMTimeRangeInvalid;
    if (CMTIMERANGE_IS_VALID(trimRange))
    {
        assetRange = trimRange;
    }
    else
    {
        assetRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    }
    
    // Ensure we are within the asset's time range
    assetRange = CMTimeRangeGetIntersection(CMTimeRangeMake(kCMTimeZero, asset.duration), assetRange);
    
    NSError *compositionError = nil;
    BOOL initialInsertSucceeded = [composition insertTimeRange:assetRange
                                                       ofAsset:asset
                                                        atTime:composition.duration
                                                         error:&compositionError];
    if (initialInsertSucceeded)
    {
        while (CMTIME_COMPARE_INLINE(composition.duration, <, minimumDuration))
        {
            [composition insertTimeRange:assetRange
                                 ofAsset:asset
                                  atTime:composition.duration
                                   error:&compositionError];
        }
    }
    return composition;
}

@end
