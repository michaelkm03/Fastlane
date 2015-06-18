//
//  VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "VContentViewFactory.h"
#import "VDeeplinkHandler.h"
#import "VNavigationDestination.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"
#import "VScaffoldViewController.h"
#import "VSequence+Fetcher.h"
#import "VComment.h"
#import "VTracking.h"
#import "VLightweightContentViewController.h"
#import "VFirstTimeInstallHelper.h"
#import "VAuthorizedAction.h"
#import "VAuthorizationContextProvider.h"
#import "VPushNotificationManager.h"
#import "VContentDeepLinkHandler.h"
#import "VMultipleContainer.h"
#import "VDependencyManager+VTracking.h"
#import "VSessionTimer.h"
#import "VRootViewController.h"
#import "VCoachmarkManager.h"
#import "VRootViewController.h"

#warning REMOVE
#import "VSuggestedUsersViewController.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerFirstTimeContentKey = @"firstTimeContent";
NSString * const VTrackingWelcomeVideoStartKey = @"welcome_video_start";
NSString * const VTrackingWelcomeVideoEndKey = @"welcome_video_end";
NSString * const VTrackingWelcomeStartKey = @"welcome_start";
NSString * const VTrackingWelcomeGetStartedTapKey = @"get_started_tap";

static NSString * const kShouldAutoShowLoginKey = @"showLoginOnStartup";

@interface VScaffoldViewController () <VLightweightContentViewControllerDelegate, VDeeplinkSupporter, VRootViewControllerContainedViewController>

@property (nonatomic, assign, readwrite) BOOL hasBeenShown;
@property (nonatomic, assign) BOOL isForcedRegistrationComplete;

@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, readonly) VDependencyManager *firstTimeContentDependency;
@property (nonatomic, strong) VSessionTimer *sessionTimer;

@end

@implementation VScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:_dependencyManager];
        _coachmarkManager.allowCoachmarks = [self hasShownFirstTimeUserExperience];
    }
    return self;
}

- (BOOL)shouldForceRegistration
{
    return [[self.dependencyManager numberForKey:kShouldAutoShowLoginKey] boolValue];
}

#pragma mark - Lifecyle Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.shouldForceRegistration && !self.hasBeenShown )
    {
        [self.authorizedAction prepareInViewController:self
                                               context:VAuthorizationContextDefault
                                            completion:^(BOOL authorized)
         {
             self.isForcedRegistrationComplete = YES;
             [self askForPushNotificationsPermission];
         }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.sessionTimer = [VRootViewController rootViewController].sessionTimer;
    
    BOOL didShowFirstTimeUserExperience = NO;
    if ( !self.hasBeenShown )
    {
        self.hasBeenShown = YES;
        didShowFirstTimeUserExperience = [self showFirstTimeUserExperience];
    }
    
    if ( !didShowFirstTimeUserExperience )
    {
        [self askForPushNotificationsPermission];
    }
}

- (void)askForPushNotificationsPermission
{
    // If conditions are correct, ask for push notifications permission
    const BOOL hasAskedForPushNotificationsPermission = [[VPushNotificationManager sharedPushNotificationManager] started];
    const BOOL forceRegistrationNotRequired = !self.shouldForceRegistration;
    const BOOL forceRegistrationComplete = self.shouldForceRegistration && self.isForcedRegistrationComplete;
    
    if ( !hasAskedForPushNotificationsPermission && (forceRegistrationComplete || forceRegistrationNotRequired) )
    {
        [[VPushNotificationManager sharedPushNotificationManager] startPushNotificationManager];
    }
}

#pragma mark - First Time User Experience

- (BOOL)showFirstTimeUserExperience
{
    VFirstTimeInstallHelper *firstTimeInstallHelper = [[VFirstTimeInstallHelper alloc] init];

    if ( ![self hasShownFirstTimeUserExperience] )
    {
        VLightweightContentViewController *lightweightContentVC = [self.dependencyManager templateValueOfType:[VLightweightContentViewController class]
                                                                                                       forKey:VScaffoldViewControllerFirstTimeContentKey];
        if ( lightweightContentVC != nil )
        {
            lightweightContentVC.delegate = self;
            [self presentViewController:lightweightContentVC animated:YES completion:^
            {
                //Finished presenting the FTUE VC, save that we showed the first time user experience.
                [firstTimeInstallHelper savePlaybackDefaults];
                self.coachmarkManager.allowCoachmarks = YES;
            }];
            [self trackFirstTimeContentView];
            return YES;
        }
        else
        {
            //Didn't have a valid FTUE VC to show, but we wanted to show it,
            //so we should save that we tried to show it as to not try again.
            [firstTimeInstallHelper savePlaybackDefaults];
            self.coachmarkManager.allowCoachmarks = YES;
        }
    }
    
    return NO;
}

- (BOOL)hasShownFirstTimeUserExperience
{
    VFirstTimeInstallHelper *firstTimeInstallHelper = [[VFirstTimeInstallHelper alloc] init];
    return [firstTimeInstallHelper hasBeenShown] || [[self.dependencyManager numberForKey:kShouldAutoShowLoginKey] boolValue];
}

- (VDependencyManager *)firstTimeContentDependency
{
    NSDictionary *configuration = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerFirstTimeContentKey];
    return [self.dependencyManager childDependencyManagerWithAddedConfiguration:configuration];
}

#pragma mark - Content View

- (void)showContentViewWithSequence:(id)sequence streamID:(NSString *)streamId commentId:(NSNumber *)commentID placeHolderImage:(UIImage *)placeholderImage
{
    VContentViewFactory *contentViewFactory = [self.dependencyManager contentViewFactory];
    
    NSString *reason = nil;
    if ( ![contentViewFactory canDisplaySequence:sequence localizedReason:&reason] )
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:reason preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIViewController *contentView = [contentViewFactory contentViewForSequence:sequence inStreamWithID:streamId commentID:commentID placeholderImage:placeholderImage];
    if ( contentView != nil )
    {
        if ( self.presentedViewController )
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        [self presentViewController:contentView animated:YES completion:nil];
    }
}

#pragma mark - VLightweightContentViewControllerDelegate

- (void)trackFirstTimeContentView
{
    NSDictionary *params = @{ VTrackingKeyUrls : [self.firstTimeContentDependency trackingURLsForKey:VTrackingWelcomeStartKey],
                              VTrackingKeySessionTime : @(self.sessionTimer.sessionDuration) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventWelcomeDidStart parameters:params];
}

- (void)videoHasStartedInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    NSDictionary *params = @{ VTrackingKeyUrls : [self.firstTimeContentDependency trackingURLsForKey:VTrackingWelcomeVideoStartKey],
                              VTrackingKeySessionTime : @(self.sessionTimer.sessionDuration) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventWelcomeVideoDidStart parameters:params];
}

- (void)videoHasCompletedInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    NSDictionary *params = @{ VTrackingKeyUrls : [self.firstTimeContentDependency trackingURLsForKey:VTrackingWelcomeVideoEndKey],
                              VTrackingKeySessionTime : @(self.sessionTimer.sessionDuration) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventWelcomeVideoDidEnd parameters:params];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)failedToLoadSequenceInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userWantsToDismissLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    NSDictionary *params = @{ VTrackingKeyUrls : [self.firstTimeContentDependency trackingURLsForKey:VTrackingWelcomeGetStartedTapKey],
                              VTrackingKeySessionTime : @(self.sessionTimer.sessionDuration) };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectWelcomeGetStarted parameters:params];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Authorized actions

- (VAuthorizedAction *)authorizedAction
{
    if ( _authorizedAction == nil )
    {
        _authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                           dependencyManager:self.dependencyManager];
    }
    return _authorizedAction;
}

#pragma mark - VDeeplinkSupporter

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    return [[VContentDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager];
}

#pragma mark - Navigation

- (NSArray *)navigationDestinations
{
    return @[];
}

- (void)navigateToDestination:(id)navigationDestination animated:(BOOL)animated
{
    [self navigateToDestination:navigationDestination
                       animated:animated
                     completion:nil];
}

- (void)navigateToDestination:(id)navigationDestination
                     animated:(BOOL)animated
                   completion:(void(^)())completion
{
    [self checkAuthorizationOnNavigationDestination:navigationDestination
                                         completion:^(BOOL shouldNavigate)
     {
         if (shouldNavigate)
         {
             [self _navigateToDestination:navigationDestination
                                 animated:animated
                               completion:completion];
         }
     }];
}

- (void)checkAuthorizationOnNavigationDestination:(id)navigationDestination
                                       completion:(void(^)(BOOL shouldNavigate))completion
{
    NSAssert(completion != nil, @"We need a completion to inform about the authorization check success!");
    
    if ([navigationDestination conformsToProtocol:@protocol(VAuthorizationContextProvider)])
    {
        id <VAuthorizationContextProvider> authorizationContextProvider = (id <VAuthorizationContextProvider>)navigationDestination;
        BOOL requiresAuthoriztion = [authorizationContextProvider requiresAuthorization];
        if (requiresAuthoriztion)
        {
            VAuthorizationContext context = [authorizationContextProvider authorizationContext];
            VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                                 dependencyManager:self.dependencyManager];
            [authorizedAction performFromViewController:self context:context completion:^(BOOL authorized)
             {
                 completion(authorized);
             }];
        }
        else
        {
            completion(YES);
        }
    }
    else
    {
        completion(YES);
    }
}

- (void)_navigateToDestination:(id)navigationDestination
                      animated:(BOOL)animated
                   completion:(void(^)())completion
{
    UIViewController *alternateDestination = nil;
    BOOL shouldNavigateToAlternateDestination = NO;
    
    if ([navigationDestination respondsToSelector:@selector(shouldNavigateWithAlternateDestination:)])
    {
        shouldNavigateToAlternateDestination = [navigationDestination shouldNavigateWithAlternateDestination:&alternateDestination];
        if (!shouldNavigateToAlternateDestination)
        {
            if (completion != nil)
            {
                completion();
            }
            return;
        }
    }
    
    if ( shouldNavigateToAlternateDestination && alternateDestination != nil )
    {
        [self navigateToDestination:alternateDestination animated:animated completion:completion];
    }
    else
    {
        NSAssert([navigationDestination isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
        [self displayResultOfNavigation:navigationDestination animated:animated];
        
        if ( completion != nil )
        {
            completion();
        }
    }
}

- (void)displayResultOfNavigation:(UIViewController *)viewController animated:(BOOL)animated
{
    VLog(@"WARNING: %@ does not override -displayResultOfNavigation:", NSStringFromClass([self class]));
}

- (void)showWebBrowserWithURL:(NSURL *)URL
{
    VContentViewFactory *contentViewFactory = [self.dependencyManager contentViewFactory];
    UIViewController *contentView = [contentViewFactory webContentViewControllerWithURL:URL];
    if ( contentView != nil )
    {
        if ( self.presentedViewController )
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        [self presentViewController:contentView animated:YES completion:nil];
    }
}

#pragma mark - VRootViewControllerContainedViewController

- (void)onLoadingCompletion
{
    [self.authorizedAction execute];
}

@end
