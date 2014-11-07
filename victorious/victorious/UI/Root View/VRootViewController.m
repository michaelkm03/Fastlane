//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForceUpgradeViewController.h"
#import "VLoadingViewController.h"
#import "VMultipleStreamViewController.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
#import "VSessionTimer.h"
#import "VSettingManager.h"
#import "VStreamCollectionViewController.h"
#import "VConstants.h"

static const NSTimeInterval kAnimationDuration = 0.2;

@interface VRootViewController ()

@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadingCompleted:) name:VLoadingViewControllerLoadingCompletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSessionShouldStart:) name:VSessionTimerNewSessionShouldStart object:nil];
    [self showLoadingViewController];
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

#pragma mark - Status Bar Appearance

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.currentViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.currentViewController;
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return self.currentViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    return [self.currentViewController shouldAutorotate];
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
{
    return parentSize;
}

#pragma mark - Force Upgrade

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

#pragma mark - Child View Controllers

- (void)showLoadingViewController
{
    VLoadingViewController *loadingViewController = [VLoadingViewController loadingViewController];
    [self showViewController:loadingViewController animated:NO];
}

- (void)showHomeStream
{
    VSideMenuViewController *sideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VSideMenuViewController class])];
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    UIViewController *homeVC = isTemplateC ? [VMultipleStreamViewController homeStream] : [VStreamCollectionViewController homeStreamCollection];
    [sideMenuViewController transitionToNavStack:@[homeVC]];
    [self showViewController:sideMenuViewController animated:YES];
}

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController)
    {
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        viewController.view.frame = self.view.bounds;
    }
    
    void (^finishingTasks)() = ^(void)
    {
        [viewController didMoveToParentViewController:self];
        [UIViewController attemptRotationToDeviceOrientation];
    };
    
    if (self.currentViewController)
    {
        UIViewController *fromViewController = self.currentViewController;
        
        if (fromViewController.presentedViewController)
        {
            [fromViewController dismissViewControllerAnimated:NO completion:nil];
        }
        [fromViewController willMoveToParentViewController:nil];
        
        void (^removeViewController)(BOOL) = ^(BOOL complete)
        {
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            finishingTasks();
        };
        
        if (animated)
        {
            viewController.view.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 1.5f, CGRectGetMidY(self.view.bounds));
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^(void)
                                        {
                                            viewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
                                        }
                             completion:removeViewController];
        }
        else
        {
            removeViewController(YES);
        }
    }
    else
    {
        finishingTasks();
    }
    
    self.currentViewController = viewController;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - NSNotifications

- (void)loadingCompleted:(NSNotification *)notification
{
    [self showHomeStream];
}

- (void)newSessionShouldStart:(NSNotification *)notification
{
    [self showViewController:nil animated:NO];
    [RKObjectManager setSharedManager:nil];
    [VObjectManager setupObjectManager];
    [self showLoadingViewController];
}

@end
