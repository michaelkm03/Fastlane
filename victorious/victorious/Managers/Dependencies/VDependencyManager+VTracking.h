//
//  VDependencyManager+VTracking.h
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VTrackingURLAppStartKey;
extern NSString * const VTrackingURLAppStopKey;
extern NSString * const VTrackingURLInitKey;
extern NSString * const VTrackingURLInstallKey;
extern NSString * const VTrackingURLBallisticCountKey;

@interface VDependencyManager (VTracking)

/**
 Returns an array of tracking URL strings associated with the given key
 
 @param eventURLKey One of the VTrackingURLKey string constants found in VDependencyManager+VTracking.h
 
 @return an array of NSString objects
 */
- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey;

@end
