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
extern NSString * const VTrackingCreateProfileStartKey;
extern NSString * const VTrackingRegistrationEndKey;
extern NSString * const VTrackingRegistrationStartKey;
extern NSString * const VTrackingCreateProfileDoneButtonTapKey;
extern NSString * const VTrackingRegisteButtonTapKey;
extern NSString * const VTrackingSignUpButtonTapKey;

extern NSString * const VTrackingBallisticCountKey;

@interface VDependencyManager (VTracking)

/**
 Returns an array of tracking URL strings associated with the given key
 
 @param eventURLKey One of the VTracking string constants found in VDependencyManager+VTracking.h
 
 @return an array of NSString objects
 */
- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey;

/**
 Uses VTrackingManager to track a view of the provided view controller if self contains the "view" tracking key.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 */
- (void)v_trackViewWillAppear:(UIViewController *)viewController;

/**
 Uses VTrackingManager to track a view of the provided view controller if self contains the "view" tracking key.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 @param parameters Dictionary of parameters to include with the event.
 */
- (void)v_trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters;

/**
 Updates state management to prevent tracking views when returning to the viewc controller
 after popping or dismissing, i.e. going back or closing.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 */
- (void)v_trackViewWillDisappear:(UIViewController *)viewController;

@end
