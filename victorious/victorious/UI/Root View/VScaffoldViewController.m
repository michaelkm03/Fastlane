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
#import "VPushNotificationManager.h"
#import "VContentDeepLinkHandler.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerFirstTimeContentKey = @"firstTimeContent";

@interface VScaffoldViewController () <VLightweightContentViewControllerDelegate, VDeeplinkSupporter>

@property (nonatomic) BOOL pushNotificationsRegistered;
@property (nonatomic, strong) VAuthorizedAction *authorizedAction;

@end

@implementation VScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

#pragma mark - Lifecyle Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL didShow = [self showFirstTimeUserExperience];
    if ( !self.pushNotificationsRegistered && !didShow )
    {
        [[VPushNotificationManager sharedPushNotificationManager] startPushNotificationManager];
        self.pushNotificationsRegistered = YES;
    }
    
#warning Use these to test deep links in dev environment, app ID=1 (will remove before merge to dev branch)
    //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://inbox/491"];
    //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://content/11377"];
    //NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://comment/11377/7511"];
    NSURL *testDeepLinkURL = [NSURL URLWithString:@"vthisapp://profile/1677"];
    [self performSelector:@selector(navigateToDeeplinkURL:) withObject:testDeepLinkURL afterDelay:1.0];
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
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OKButton", @"") style:UIAlertActionStyleDefault handler:nil]];
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

#pragma mark - Deeplinks

- (void)navigateToDeeplinkURL:(NSURL *)url
{
    if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:YES completion:^(void)
        {
            [self navigateToDeeplinkURL:url];
        }];
        return;
    }
    
    __block MBProgressHUD *hud;
    VDeeplinkHandlerCompletionBlock completion = ^(UIViewController *viewController)
    {
        [hud hide:YES];
        if ( viewController == nil )
        {
            [self showBadDeeplinkError];
        }
        else
        {
            [self navigateToDestination:viewController];
        }
    };

    BOOL wasDeeplinkHandled = NO;
    NSArray *possibleDeeplinkSupporters = [[self navigationDestinations] arrayByAddingObject:self];
    for ( id<VDeeplinkSupporter> supporter in possibleDeeplinkSupporters )
    {
        if ( [supporter conformsToProtocol:@protocol(VDeeplinkSupporter)] )
        {
            id<VDeeplinkHandler> handler = [supporter deeplinkHandler];
            if ( [handler canDisplayContentForDeeplinkURL:url] )
            {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                wasDeeplinkHandled = [handler displayContentForDeeplinkURL:url completion:completion];
                break;
            }
        }
    }
    if ( !wasDeeplinkHandled )
    {
        [self showBadDeeplinkError];
    }
}

- (void)showBadDeeplinkError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                    message:NSLocalizedString(@"Missing Content Message", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - VDeeplinkSupporter

- (id<VDeeplinkHandler>)deeplinkHandler
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
    [self navigateToDestination:navigationDestination completion:nil];
}

- (void)navigateToDestination:(id)navigationDestination completion:(void(^)())completion
{
    void (^performNavigation)(UIViewController *) = ^(UIViewController *viewController)
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
            NSAssert([viewController isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
            [self displayResultOfNavigation:viewController];

            if ( completion != nil )
            {
                completion();
            }
        }
    };

    if ([navigationDestination respondsToSelector:@selector(authorizationContext)] )
    {
        VAuthorizationContext context = [navigationDestination authorizationContext];
        [self.authorizedAction performFromViewController:self context:context completion:^(BOOL authorized)
         {
             if (!authorized)
             {
                 return;
             }
            performNavigation(navigationDestination);
        }];
    }
    else
    {
        performNavigation(navigationDestination);
    }
}

- (void)displayResultOfNavigation:(UIViewController *)viewController
{
    VLog(@"WARNING: %@ does not override -displayResultOfNavigation:", NSStringFromClass([self class]));
}

@end
