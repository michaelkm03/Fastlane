//
//  VDependencyManager+VTracking.h
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VTrackingStartKey;
extern NSString * const VTrackingStopKey;
extern NSString * const VTrackingInitKey;
extern NSString * const VTrackingInstallKey;
extern NSString * const VTrackingBallisticCountKey;

@interface VDependencyManager (VTracking)

/**
 Returns an array of tracking URL strings associated with the given key
 
 @param eventURLKey One of the VTracking string constants found in VDependencyManager+VTracking.h
 
 @return an array of NSString objects
 */
- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey;

@end
