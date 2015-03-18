//
//  VDependencyManager+VTracking.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VTracking.h"

NSString * const VTrackingURLAppStartKey = @"start";
NSString * const VTrackingURLAppStopKey = @"stop";
NSString * const VTrackingURLInitKey = @"init";
NSString * const VTrackingURLInstallKey = @"install";

static NSString * const kTrackingKey = @"tracking";

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    NSDictionary *tracking = [self templateValueOfType:[NSDictionary class] forKey:kTrackingKey];
    return tracking[eventURLKey];
}

@end
