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
extern NSString * const VTrackingPermissionChangeKey;
extern NSString * const VTrackingAppErrorKey;

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
- (void)trackViewWillAppear:(UIViewController *)viewController;

/**
 Uses VTrackingManager to track a view of the provided view controller if self contains the "view" tracking key.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 @param parameters Dictionary of parameters to include with the event.
 */
- (void)trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters;

/**
 Uses VTrackingManager to track a view of the provided view controller if self contains the "view" tracking key.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 @param parameters Dictionary of parameters to include with the event.
 @param tempalteClass A `Class` type that allows the view controller to specify a template class as the source
 of the view event.  Internally, this category prevents duplicate tracking events by checking that the class
 of the view controller provided to this method is actually the class that corresponds to the template component
 (such as a ".screen" component) as configured in templateClasses.plist.  If that's not the case, the event is
 not tracked under the assumption that the event was trigger by a view controller that whose dependency manager
 is inherited from another view controller that instantiated it, and therefore is not the view controller representation
 of the template component (because it's parent is).  Anyway, the `templateClass` parameter allows the caller
 to override that by forcing that comparison to use the provided class.  This is required in situations where the
 template structure or some other functionality is breaking that normal usecase,  such as is the case with navigation
 destinations that provide alternate destinations.
 */
- (void)trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters templateClass:(Class)templateClass;

/**
 Updates state management to prevent tracking views when returning to the viewc controller
 after popping or dismissing, i.e. going back or closing.
 
 @param viewController The view controller spawned by this instance of VDependencyManager that
 contains tracking keys and other values relative to it.
 */
- (void)trackViewWillDisappear:(UIViewController *)viewController;

@end
