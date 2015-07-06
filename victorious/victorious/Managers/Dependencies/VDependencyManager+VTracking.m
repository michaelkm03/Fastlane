//
//  VDependencyManager+VTracking.m
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <objc/runtime.h>
#import "VDependencyManager+VTracking.h"
#import "VTrackingManager.h"

NSString * const VTrackingStartKey                      = @"start";
NSString * const VTrackingStopKey                       = @"stop";
NSString * const VTrackingInitKey                       = @"init";
NSString * const VTrackingInstallKey                    = @"install";
NSString * const VTrackingBallisticCountKey             = @"ballistic_count";
NSString * const VTrackingCreateProfileStartKey         = @"create_profile_start";
NSString * const VTrackingRegistrationEndKey            = @"registration_end";
NSString * const VTrackingRegistrationStartKey          = @"registration_start";
NSString * const VTrackingCreateProfileDoneButtonTapKey = @"create_profile_done_button_tap";
NSString * const VTrackingRegisteButtonTapKey           = @"register_button_tap";
NSString * const VTrackingSignUpButtonTapKey            = @"sign_up_button_tap";

static NSString * const kTrackingViewKey                = @"view";
static NSString * const kTrackingKey                    = @"tracking";

static const char kAssociatedObjectViewWasHiddenKey;

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    NSDictionary *tracking = [self templateValueOfType:[NSDictionary class] forKey:kTrackingKey];
    return tracking[ eventURLKey ] ?: @[];
}

- (void)trackViewWillAppear:(UIViewController *)viewController
{
    [self trackViewWillAppear:viewController withParameters:nil];
}

- (void)trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters
{
    NSNumber *number = objc_getAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey );
    BOOL wasHidden = number.boolValue;
    if ( !wasHidden )
    {
        NSArray *urls = [self trackingURLsForKey:kTrackingViewKey];
        
        if ( urls  == nil )
        {
            VLog( @"A template component must have a tracking 'viewability' to be tracked with `trackViewWithParameters:`." );
            return;
        }
        
        NSMutableDictionary *combined = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        combined[ VTrackingKeyUrls ] = urls;
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventComponentDidBecomeVisible
                                           parameters:[NSDictionary dictionaryWithDictionary:combined]];
    }
    
    objc_setAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey, @NO, OBJC_ASSOCIATION_ASSIGN );
}

- (void)trackViewWillDisappear:(UIViewController *)viewController
{
    BOOL wasHidden = viewController.navigationController.viewControllers.count > 1 || viewController.presentedViewController != nil;
    objc_setAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey, @(wasHidden), OBJC_ASSOCIATION_ASSIGN );
}

@end
