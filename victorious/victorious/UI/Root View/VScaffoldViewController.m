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
#import "VNavigationController.h"

#import <MBProgressHUD.h>

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerContentViewComponentKey = @"contentView";
NSString * const VScaffoldViewControllerUserProfileViewComponentKey = @"userProfileView";

static NSString * const kContentDeeplinkURLHostComponent = @"content";
static NSString * const kCommentDeeplinkURLHostComponent = @"comment";

@interface VScaffoldViewController () <VNewContentViewControllerDelegate>

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
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel
                                                                                                   dependencyManager:self.dependencyManager];
    contentViewController.dependencyManagerForHistogramExperiment = self.dependencyManager;
    contentViewController.placeholderImage = placeHolderImage;
    contentViewController.delegate = self;
    
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
    void (^goTo)(UIViewController *) = ^(UIViewController *viewController)
    {
        NSAssert([viewController isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
        [self displayResultOfNavigation:viewController];
    };
    
    if ([navigationDestination respondsToSelector:@selector(shouldNavigateWithAlternateDestination:)])
    {
        UIViewController *alternateDestination = nil;
        if ( [navigationDestination shouldNavigateWithAlternateDestination:&alternateDestination] )
        {
            if ( alternateDestination == nil )
            {
                goTo(navigationDestination);
            }
            else
            {
                [self navigateToDestination:alternateDestination];
            }
        }
    }
    else
    {
        goTo(navigationDestination);
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
