//
//  VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSURL+VPathHelper.h"
#import "VContentViewViewModel.h"
#import "VDeeplinkHandler.h"
#import "VDependencyManager+VObjectManager.h"
#import "VNavigationDestination.h"
#import "VNavigationDestinationsProvider.h"
#import "VNewContentViewController.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Pagination.h"
#import "VScaffoldViewController.h"
#import "VSequence+Fetcher.h"
#import "VComment.h"
#import "VTracking.h"
#import "VWebBrowserViewController.h"
#import "VLightweightContentViewController.h"
#import "VNavigationController.h"
#import "VFirstTimeInstallHelper.h"
#import "VAuthorizedAction.h"

#import <MBProgressHUD.h>

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerContentViewComponentKey = @"contentView";
NSString * const VScaffoldViewControllerUserProfileViewComponentKey = @"userProfileView";
NSString * const VScaffoldViewControllerLightweightContentViewComponentKey = @"firstTimeContent";

static NSString * const kContentDeeplinkURLHostComponent = @"content";
static NSString * const kCommentDeeplinkURLHostComponent = @"comment";

@interface VScaffoldViewController () <VNewContentViewControllerDelegate, VLightweightContentViewControllerDelegate>

@property (nonatomic, strong) VFirstTimeInstallHelper *firstTimeInstallHelper;

@end

@implementation VScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _menuViewController = [dependencyManager viewControllerForKey:VScaffoldViewControllerMenuComponentKey];
    }
    return self;
}

#pragma mark - Lifecyle Methods

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self showFirstTimeUserExperience];
}

#pragma mark - First Time User Experience

- (void)showFirstTimeUserExperience
{
    // Show the First Time User Video if it hasn't been shown yet
    VLightweightContentViewController *lightweightContentVC = [self.dependencyManager templateValueOfType:[VLightweightContentViewController class]
                                                                                                   forKey:VScaffoldViewControllerLightweightContentViewComponentKey];

    self.firstTimeInstallHelper = [[VFirstTimeInstallHelper alloc] init];

    // Present the first-time user video view controller if hasn't been shown
    if ( ![self.firstTimeInstallHelper hasBeenShown] )
    {
        lightweightContentVC.delegate = self;
        double delayInSeconds = 1.0;
        dispatch_time_t showTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(showTime, dispatch_get_main_queue(), ^(void)
                       {
                           if ( lightweightContentVC.mediaUrl != nil )
                           {
                               [self presentViewController:lightweightContentVC animated:YES completion:^
                               {
                                   [self.firstTimeInstallHelper savePlaybackDefaults];
                               }];
                           }
                       });
    }
}

#pragma mark - Content View

- (void)showContentViewWithSequence:(id)sequence commentId:(NSNumber *)commentId placeHolderImage:(UIImage *)placeHolderImage
{
    if ( [sequence isWebContent] )
    {
        [self showWebContentWithSequence:sequence];
        return;
    }

    if ( self.presentedViewController )
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }

    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence depenencyManager:self.dependencyManager];
    contentViewModel.deepLinkCommentId = commentId;
    VNewContentViewController *contentViewController = [self.dependencyManager contentViewControllerForKey:VScaffoldViewControllerContentViewComponentKey withViewModel:contentViewModel];
    contentViewController.placeholderImage = placeHolderImage;
    contentViewController.delegate = self;
    
    if ( contentViewController == nil )
    {
        return;
    }
    VNavigationController *contentNav = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
    contentNav.innerNavigationController.viewControllers = @[contentViewController];
    contentNav.innerNavigationController.navigationBarHidden = YES;
    [self presentViewController:contentNav animated:YES completion:nil];
}

- (void)showWebContentWithSequence:(VSequence *)sequence
{
    NSURL *sequenceContentURL = [NSURL URLWithString:sequence.webContentUrl];
    const BOOL isCustomScheme = [sequenceContentURL.scheme rangeOfString:@"http"].location != 0;
    if ( isCustomScheme && [[UIApplication sharedApplication] canOpenURL:sequenceContentURL] )
    {
        [[UIApplication sharedApplication] openURL:sequenceContentURL];
    }
    else
    {
        VWebBrowserViewController *viewController = [VWebBrowserViewController instantiateFromStoryboard];
        viewController.sequence = sequence;
        [self presentViewController:viewController
                           animated:YES
                         completion:^(void)
         {
             // Track view-start event, similar to how content is tracking in VNewContentViewController when loaded
             NSDictionary *params = @{ VTrackingKeyTimeCurrent : [NSDate date],
                                       VTrackingKeySequenceId : sequence.remoteId,
                                       VTrackingKeyUrls : sequence.tracking.viewStart ?: @[] };
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventViewDidStart parameters:params];
         }];
    }
}

#pragma mark - VLightweightContentViewControllerDelegate

- (void)videoHasCompleted:(VLightweightContentViewController *)firstTimeUserVideoViewController
{
    [firstTimeUserVideoViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoHasStarted:(VLightweightContentViewController *)lightweightContentVideoViewController
{
    // Tracking
    NSDictionary *vcDictionary = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:VScaffoldViewControllerLightweightContentViewComponentKey];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:vcDictionary];

    NSArray *trackingUrlArray = [childDependencyManager arrayForKey:kFTUTrackingURLGroup];
    if ( trackingUrlArray != nil )
    {
        NSDictionary *params = @{ VTrackingKeyUrls: trackingUrlArray };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventFirstTimeUserVideoPlayed parameters:params];
    }
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

    if ( [self displayContentViewForDeeplinkURL:url] )
    {
        return;
    }
    else if ( [self.menuViewController respondsToSelector:@selector(navigationDestinations)] )
    {
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

        NSArray *possibleHandlers = [(id<VNavigationDestinationsProvider>)self.menuViewController navigationDestinations];
        for (id<VDeeplinkHandler> handler in possibleHandlers)
        {
            if ( [handler conformsToProtocol:@protocol(VDeeplinkHandler)] )
            {
                if ( [handler displayContentForDeeplinkURL:url completion:completion] )
                {
                    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    return;
                }
            }
        }
    }
    [self showBadDeeplinkError];
}

/**
 Displays a content view for deeplink URLs that point to content views.

 @return YES if the given URL was a content URL, or NO if it was
         some other kind of deep link.
 */
- (BOOL)displayContentViewForDeeplinkURL:(NSURL *)url
{
    if ( ![url.host isEqualToString:kContentDeeplinkURLHostComponent] && ![url.host isEqualToString:kCommentDeeplinkURLHostComponent] )
    {
        return NO;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *sequenceID = [url v_firstNonSlashPathComponent];
    if ( sequenceID == nil )
    {
        return NO;
    }

    NSNumber *commentId = @([url v_pathComponentAtIndex:2].integerValue);

    [[self.dependencyManager objectManager] fetchSequenceByID:sequenceID
                                                 successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [hud hide:YES];
        VSequence *sequence = (VSequence *)[resultObjects firstObject];
        [self showContentViewWithSequence:sequence commentId:commentId placeHolderImage:nil];
    }
                                                    failBlock:^(NSOperation *operation, NSError *error)
    {
        [hud hide:YES];
        VLog(@"Failed with error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                        message:NSLocalizedString(@"Missing Content Message", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];

    return YES;
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

#pragma mark - Navigation

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
        VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                        dependencyManager:self.dependencyManager];
        [authorizedAction performFromViewController:self context:context completion:^
         {
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

#pragma mark - VNewContentViewControllerDelegate methods

- (void)newContentViewControllerDidClose:(VNewContentViewController *)contentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newContentViewControllerDidDeleteContent:(VNewContentViewController *)contentViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
