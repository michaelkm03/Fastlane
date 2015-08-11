//
//  VTabScaffoldViewController.m
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabScaffoldViewController.h"

// Views + Helpers
#import "UIView+AutoLayout.h"

// Backgrounds
#import "VSolidColorBackground.h"

// Dependencies
#import "VTabMenuShim.h"
#import "VCoachmarkManager.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerFirstTimeContentKey = @"firstTimeContent";
NSString * const VTrackingWelcomeVideoStartKey = @"welcome_video_start";
NSString * const VTrackingWelcomeVideoEndKey = @"welcome_video_end";
NSString * const VTrackingWelcomeStartKey = @"welcome_start";
NSString * const VTrackingWelcomeGetStartedTapKey = @"get_started_tap";
NSString * const kMenuKey = @"menu";

@interface VTabScaffoldViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (nonatomic, strong) UITabBarController *internalTabBarController;

@property (nonatomic, strong) VTabMenuShim *tabShim;

@end

@implementation VTabScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _internalTabBarController = [[UITabBarController alloc] init];
        _rootNavigationController = [[UINavigationController alloc] initWithRootViewController:_internalTabBarController];
        _dependencyManager = dependencyManager;
        _coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:_dependencyManager];
        _tabShim = [dependencyManager templateValueOfType:[VTabMenuShim class] forKey:kMenuKey];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.rootNavigationController];
    self.rootNavigationController.view.frame = self.view.bounds;
    self.rootNavigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.rootNavigationController.navigationBarHidden = YES;
    [self.view addSubview:self.rootNavigationController.view];
    [self.view v_addFitToParentConstraintsToSubview:self.rootNavigationController.view];
    [self.rootNavigationController didMoveToParentViewController:self];
    
    // Configure Tab Bar
    [self.internalTabBarController.tabBar setTintColor:self.tabShim.selectedIconColor];
    VBackground *backgroundForTabBar = self.tabShim.background;
    if ([backgroundForTabBar isKindOfClass:[VSolidColorBackground class]])
    {
        VSolidColorBackground *solidColorBackground = (VSolidColorBackground *)backgroundForTabBar;
        self.internalTabBarController.tabBar.translucent = NO;
        self.internalTabBarController.tabBar.barTintColor = solidColorBackground.backgroundColor;
    }
    self.internalTabBarController.viewControllers = [self.tabShim wrappedNavigationDesinations];
}

#pragma mark - Public API

- (void)showContentViewWithSequence:(id)sequence streamID:(NSString *)streamId commentId:(NSNumber *)commentID placeHolderImage:(UIImage *)placeholderImage
{
    
}

- (void)navigateToDestination:(id)navigationDestination animated:(BOOL)animated completion:(void(^)())completion
{
    
}

- (void)navigateToDestination:(id)navigationDestination animated:(BOOL)animated
{
    
}

- (void)displayResultOfNavigation:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)showWebBrowserWithURL:(NSURL *)URL
{
    
}

#pragma mark - VRootViewControllerContainedViewController

- (void)onLoadingCompletion
{
//    [self.authorizedAction execute];
}

#pragma mark - UITabBarControllerDelegate

@end

@implementation UIViewController (VRootNavigationController)

- (UINavigationController *)rootNavigationController
{
    UINavigationController *rootNavigationController = [self recursiveRootViewControllerSearch];
    
    return rootNavigationController;
}

- (UINavigationController *)recursiveRootViewControllerSearch
{
    UIViewController *parentViewController = self.parentViewController;
    if ([parentViewController isKindOfClass:[VTabScaffoldViewController class]])
    {
        return (UINavigationController *)self;
    }
    else if (parentViewController == nil)
    {
        return nil;
    }
    else
    {
        return [parentViewController recursiveRootViewControllerSearch];
    }
}

@end
