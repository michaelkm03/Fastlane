//
//  VScaffoldViewController.m
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentViewViewModel.h"
#import "VDependencyManager.h"
#import "VNavigationDestination.h"
#import "VNewContentViewController.h"
#import "VScaffoldViewController.h"
#import "VSequence+Fetcher.h"
#import "VTracking.h"
#import "VWebBrowserViewController.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerContentViewComponentKey = @"contentView";

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

- (void)showContentViewWithSequence:(id)sequence placeHolderImage:(UIImage *)placeHolderImage
{
    if ( [sequence isWebContent] )
    {
        [self showWebContentWithSequence:sequence];
        return;
    }
    
    VContentViewViewModel *contentViewModel = [[VContentViewViewModel alloc] initWithSequence:sequence];
    VNewContentViewController *contentViewController = [VNewContentViewController contentViewControllerWithViewModel:contentViewModel];
    contentViewController.dependencyManagerForHistogramExperiment = self.dependencyManager;
    contentViewController.placeholderImage = placeHolderImage;
    contentViewController.delegate = self;
    
    UINavigationController *contentNav = [[UINavigationController alloc] initWithRootViewController:contentViewController];
    contentNav.navigationBarHidden = YES;
    [self presentViewController:contentNav animated:YES completion:nil];
}

- (void)showWebContentWithSequence:(VSequence *)sequence
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

#pragma mark - Navigation

- (void)navigateToDestination:(id)navigationDestination
{
    void (^goTo)(UIViewController *) = ^(UIViewController *vc)
    {
        NSAssert([vc isKindOfClass:[UIViewController class]], @"non-UIViewController specified as destination for navigation");
        [self displayResultOfNavigation:vc];
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

#pragma mark -

@implementation VDependencyManager (VScaffoldViewController)

- (VScaffoldViewController *)scaffoldViewController
{
    return [self singletonObjectOfType:[VScaffoldViewController class] forKey:VDependencyManagerScaffoldViewControllerKey];
}

@end
