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
#import "VDependencyManager+VTracking.h"
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
#import "VFollowingHelper.h"
#import "VFollowResponder.h"
#import "VURLSelectionResponder.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerFirstTimeContentKey = @"firstTimeContent";

@interface VScaffoldViewController () <VLightweightContentViewControllerDelegate, VDeeplinkSupporter, VURLSelectionResponder>

@property (nonatomic) BOOL pushNotificationsRegistered;
@property (nonatomic, strong) VAuthorizedAction *authorizedAction;
@property (nonatomic, assign, readwrite) BOOL hasBeenShown;

@property (nonatomic, strong) VFollowingHelper *followHelper;

@end

@implementation VScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        
        _followHelper = [[VFollowingHelper alloc] initWithDependencyManager:dependencyManager
                                                  viewControllerToPresentOn:self];
    }
    return self;
}

#pragma mark - Lifecyle Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL didShowFirstTimeUserExperience = NO;
    if ( !self.hasBeenShown )
    {
        self.hasBeenShown = YES;
        didShowFirstTimeUserExperience = [self showFirstTimeUserExperience];
    }
    
    if ( !didShowFirstTimeUserExperience && ![[VPushNotificationManager sharedPushNotificationManager] started] )
    {
        [[VPushNotificationManager sharedPushNotificationManager] startPushNotificationManager];
    }
}

#pragma mark - First Time User Experience

- (BOOL)showFirstTimeUserExperience
{
    VFirstTimeInstallHelper *firstTimeInstallHelper = [[VFirstTimeInstallHelper alloc] init];

    if ( ![firstTimeInstallHelper hasBeenShown] )
    {
        [firstTimeInstallHelper savePlaybackDefaults];
        VLightweightContentViewController *lightweightContentVC = [self.dependencyManager templateValueOfType:[VLightweightContentViewController class]
                                                                                                       forKey:VScaffoldViewControllerFirstTimeContentKey];
        if ( lightweightContentVC != nil )
        {
            lightweightContentVC.delegate = self;
            [self presentViewController:lightweightContentVC animated:YES completion:^(void)
            {
                [self trackFirstTimeContentView];
            }];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)trackFirstTimeContentView
{
    // Tracking
    NSDictionary *vcDictionary = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerFirstTimeContentKey];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:vcDictionary];
    
    NSArray *trackingUrlArray = [childDependencyManager trackingURLsForKey:VTrackingStartKey];
    if ( trackingUrlArray != nil )
    {
        NSDictionary *params = @{ VTrackingKeyUrls: trackingUrlArray };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventFirstTimeUserVideoPlayed parameters:params];
    }
}

#pragma mark - Content View

- (void)showContentViewWithSequence:(id)sequence commentId:(NSNumber *)commentID placeHolderImage:(UIImage *)placeholderImage
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
    
    UIViewController *contentView = [contentViewFactory contentViewForSequence:sequence commentID:commentID placeholderImage:placeholderImage];
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

- (void)videoHasCompletedInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)failedToLoadSequenceInLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userWantsToDismissLightweightContentView:(VLightweightContentViewController *)lightweightContentViewController
{
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

- (id<VDeeplinkHandler>)deepLinkHandler
{
    return [[VContentDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager];
}

#pragma mark - Navigation

- (NSArray *)navigationDestinations
{
    return @[];
}

- (void)navigateToDestination:(id)navigationDestination
{
    [self navigateToDestination:navigationDestination
                     completion:nil];
}

- (void)navigateToDestination:(id)navigationDestination
                   completion:(void(^)())completion
{
    [self checkAuthorizationOnNavigationDestination:navigationDestination
                                         completion:^(BOOL shouldNavigate)
     {
         if (shouldNavigate)
         {
             [self _navigateToDestination:navigationDestination
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
        [self navigateToDestination:alternateDestination completion:completion];
    }
    else
    {
        NSAssert([navigationDestination isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
        [self displayResultOfNavigation:navigationDestination];
        
        if ( completion != nil )
        {
            completion();
        }
    }
}

- (void)displayResultOfNavigation:(UIViewController *)viewController
{
    VLog(@"WARNING: %@ does not override -displayResultOfNavigation:", NSStringFromClass([self class]));
}

#pragma mark - VFollowing

- (void)followUser:(VUser *)user
    withCompletion:(VFollowEventCompletion)completion
{
    [self.followHelper followUser:user
                   withCompletion:completion];
}

- (void)unfollowUser:(VUser *)user
      withCompletion:(VFollowEventCompletion)completion
{
    [self.followHelper unfollowUser:user
                     withCompletion:completion];
}
#pragma mark - VURLSelectionResponder

- (void)URLSelected:(NSURL *)URL
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

@end
