//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForceUpgradeViewController.h"
#import "VRootViewController.h"
#import "VMenuController.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VConstants.h"

@interface  VSideMenuViewController ()

- (void)setContentViewController:(UINavigationController *)contentViewController;

@end

@interface VRootViewController () <UINavigationControllerDelegate>

@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;

@end

@implementation VRootViewController

+ (instancetype)rootViewController
{
    VRootViewController *rootViewController = (VRootViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:self])
    {
        return rootViewController;
    }
    else
    {
        return nil;
    }
}

- (void)awakeFromNib
{
    if (IS_IPHONE_5)
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.8 maskImage:nil];
    else
        self.backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:0.0 alpha:0.75] saturationDeltaFactor:1.8 maskImage:nil];

    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VMenuController class])];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    NSAssert([self.contentViewController isKindOfClass:[UINavigationController class]], @"contentController should be a UINavigationController");
    self.contentViewController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.appearing = YES;
    if (self.shouldPresentForceUpgradeScreenOnNextAppearance)
    {
        self.shouldPresentForceUpgradeScreenOnNextAppearance = NO;
        [self _presentForceUpgradeScreen];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.appearing = NO;
}

- (void)presentForceUpgradeScreen
{
    if (self.appearing)
    {
        [self _presentForceUpgradeScreen];
    }
    else
    {
        self.shouldPresentForceUpgradeScreenOnNextAppearance = YES;
    }
}

- (void)_presentForceUpgradeScreen
{
    VForceUpgradeViewController *forceUpgradeViewController = [[VForceUpgradeViewController alloc] init];
    [self presentViewController:forceUpgradeViewController animated:YES completion:nil];
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
