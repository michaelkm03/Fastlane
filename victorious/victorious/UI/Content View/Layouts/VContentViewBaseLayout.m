//
//  VContentViewBaseLayout.m
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewBaseLayout.h"

NSString * const VContentViewBaseLayoutDecelerationLocationDesiredContentOffset = @"VContentViewBaseLayoutDecelerationLocationDesiredContentOffset";
NSString * const VContentViewBaseLayoutDecelerationLocationThresholdAbove = @"VContentViewBaseLayoutDecelerationLocationThresholdAbove";
NSString * const VContentViewBaseLayoutDecelerationLocationThresholdBelow = @"VContentViewBaseLayoutDecelerationLocationThresholdBelow";

@implementation VContentViewBaseLayout

- (NSArray *)desiredDecelerationLocations
{
    return @[
             @{VContentViewBaseLayoutDecelerationLocationDesiredContentOffset:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
               VContentViewBaseLayoutDecelerationLocationThresholdAbove:@(160.0f),
               VContentViewBaseLayoutDecelerationLocationThresholdBelow:@(160.0f)
               }
             ];
}

@end
