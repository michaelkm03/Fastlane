//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRootViewController.h"
#import "VMenuController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VConstants.h"

@interface  VSideMenuViewController ()

- (void)setContentViewController:(UINavigationController *)contentViewController;

@end

@interface VRootViewController () <UINavigationControllerDelegate>

@end

@implementation VRootViewController

- (void)awakeFromNib
{
    if (IS_IPHONE_5)
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyLightEffect];
    else
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyLightEffect];

    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuController class])];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    NSAssert([self.contentViewController isKindOfClass:[UINavigationController class]], @"contentController should be a UINavigationController");
    self.contentViewController.delegate = self;
}

#pragma mark - UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if ([fromVC respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
    {
        return [(UIViewController<UINavigationControllerDelegate>*)fromVC navigationController:navigationController
                                                               animationControllerForOperation:operation
                                                                            fromViewController:fromVC
                                                                              toViewController:toVC];
    }
    else
    {
        return nil;
    }
}

@end
