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
NSString * const VTrackingAppErrorKey                   = @"error";

static NSString * const kTrackingTimingKey              = @"app_time";
static NSString * const kTrackingViewKey                = @"view";
static NSString * const kTrackingKey                    = @"tracking";

static const char kAssociatedObjectViewWasHiddenKey;

@implementation VDependencyManager (VTracking)

- (NSArray *)trackingURLsForKey:(NSString *)eventURLKey
{
    NSDictionary *tracking = [self templateValueOfType:[NSDictionary class] forKey:kTrackingKey];
    return tracking[ eventURLKey ] ?: @[];
}

- (BOOL)isComponentForTemplateClass:(Class)templateClass
{
    NSString *componentName = [self stringForKey:@"name"];
    NSDictionary *dictionary = [self defaultDictionaryOfClassesByTemplateName];
    NSString *className = dictionary[ componentName ];
    return [className isEqualToString:NSStringFromClass(templateClass)];
}

- (void)trackViewWillAppear:(UIViewController *)viewController
{
    [self trackViewWillAppear:viewController withParameters:nil templateClass:nil];
}

- (void)trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters
{
    [self trackViewWillAppear:viewController withParameters:parameters templateClass:nil];
}

- (void)trackViewWillAppear:(UIViewController *)viewController withParameters:(NSDictionary *)parameters templateClass:(Class)templateClass
{
    NSNumber *number = objc_getAssociatedObject( viewController, &kAssociatedObjectViewWasHiddenKey );
    BOOL wasHidden = number.boolValue;
    if ( !wasHidden )
    {
        if ( ![self isComponentForTemplateClass:templateClass ?: [viewController class]] )
        {
            return;
        }
        
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

- (UIViewController *)viewControllerInNavControllerFromViewController:(UIViewController *)viewController
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
    return viewControllerInNavController;
}

- (void)trackViewWillDisappear:(UIViewController *)viewController
{
    UIViewController *viewControllerInNavController = [self viewControllerInNavControllerFromViewController:viewController];
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
