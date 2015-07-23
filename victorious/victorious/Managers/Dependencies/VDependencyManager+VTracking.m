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
#import "VMultipleContainer.h"

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
NSString * const VTrackingPermissionChangeKey           = @"permission_change";

static NSString * const kTrackingViewKey                = @"view";
static NSString * const kTrackingKey                    = @"tracking";

static const char kAssociatedObjectViewWasHiddenKey;

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    // Prevent using inherited values
    if ( ![self containsKey:kTrackingKey] )
    {
        return @[];
    }
    
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
        if ( urls.count == 0 )
        {
            return;
        }
        
        NSMutableDictionary *combined = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        combined[ VTrackingKeyUrls ] = urls;
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventComponentDidBecomeVisible
                                           parameters:[NSDictionary dictionaryWithDictionary:combined]];
    }
    
    objc_setAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (void)trackViewWillDisappear:(UIViewController *)viewController
{
    UIViewController *viewControllerInNavController = viewController;
    if ( [viewController conformsToProtocol:@protocol(VMultipleContainerChild)] )
    {
        id<VMultipleContainerChildDelegate> delegate = ((id<VMultipleContainerChild>)viewController).multipleContainerChildDelegate;
        if ( [delegate isKindOfClass:[UIViewController class]] )
        {
            viewControllerInNavController = (UIViewController *)delegate;
        }
    }
    
    NSArray *navStackAfterViewController = @[];
    NSArray *navStack = viewController.navigationController.viewControllers;
    NSInteger start = [navStack indexOfObject:viewControllerInNavController];
    if ( start != NSNotFound )
    {
        NSRange range = NSMakeRange(start, navStack.count - start);
        navStackAfterViewController = [navStack subarrayWithRange:range];
    }
    
    BOOL wasHidden = navStackAfterViewController.count > 1 ||  viewController.presentedViewController != nil;
    objc_setAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey, @(wasHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@end
