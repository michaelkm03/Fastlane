//
//  VTabScaffoldViewController.m
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTabScaffoldViewController.h"

// ViewControllers + Presenters
#import "VRootViewController.h"
#import "VContentViewPresenter.h"
#import "VContentViewFactory.h"
#import "VNavigationDestinationContainerViewController.h"
#import "VNavigationController.h"

// Views + Helpers
#import "UIView+AutoLayout.h"
#import "VTabScaffoldHidingHelper.h"

// Deep Links
#import "VDeeplinkHandler.h"
#import "VContentDeepLinkHandler.h"
#import "VNavigationDestination.h"
#import "VAuthorizationContextProvider.h"

// Backgrounds
#import "VSolidColorBackground.h"

// Dependencies
#import "VTabMenuShim.h"
#import "VCoachmarkManager.h"
#import "VDependencyManager+VTabScaffoldViewController.h"

// Etc
#import "NSArray+VMap.h"

// Swift Module
#import "victorious-Swift.h"

NSString * const VScaffoldViewControllerMenuComponentKey = @"menu";
NSString * const VScaffoldViewControllerFirstTimeContentKey = @"firstTimeContent";
NSString * const VTrackingWelcomeVideoStartKey = @"welcome_video_start";
NSString * const VTrackingWelcomeVideoEndKey = @"welcome_video_end";
NSString * const VTrackingWelcomeStartKey = @"welcome_start";
NSString * const VTrackingWelcomeGetStartedTapKey = @"get_started_tap";
NSString * const kMenuKey = @"menu";
NSString * const kFirstTimeContentKey = @"firstTimeContent";

@interface VTabScaffoldViewController () <UITabBarControllerDelegate, VRootViewControllerContainedViewController, VDeeplinkSupporter>

@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (nonatomic, strong) UITabBarController *internalTabBarController;
@property (nonatomic, strong) VNavigationDestinationContainerViewController *willSelectContainerViewController;

@property (nonatomic, strong) VTabMenuShim *tabShim;
@property (nonatomic, strong) VTabScaffoldHidingHelper *hidingHelper;
@property (nonatomic, strong) NSOperationQueue *launchOperationQueue;
@property (nonatomic, weak) AutoShowLoginOperation *loginOperation;
@property (nonatomic, assign) BOOL hasSetupFirstLaunchOperations;

@end

@implementation VTabScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _internalTabBarController = [[UITabBarController alloc] init];
        _internalTabBarController.delegate = self;
        _rootNavigationController = [[UINavigationController alloc] initWithRootViewController:_internalTabBarController];
        _dependencyManager = dependencyManager;
        _coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:_dependencyManager];
        _tabShim = [dependencyManager templateValueOfType:[VTabMenuShim class] forKey:kMenuKey];
        _launchOperationQueue = [[NSOperationQueue alloc] init];
        _launchOperationQueue.maxConcurrentOperationCount = 1;
        _hasSetupFirstLaunchOperations = NO;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.definesPresentationContext = YES;
    
    [self addChildViewController:self.rootNavigationController];
    self.rootNavigationController.view.frame = self.view.bounds;
    self.rootNavigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.rootNavigationController.navigationBarHidden = YES;
    self.rootNavigationController.navigationBar.translucent = NO;
    [self.dependencyManager applyStyleToNavigationBar:self.rootNavigationController.navigationBar];
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
    
    self.hidingHelper = [[VTabScaffoldHidingHelper alloc] initWithTabBar:_internalTabBarController.tabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFirstLaunchOperations];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Public API

- (void)showContentViewWithSequence:(id)sequence streamID:(NSString *)streamId commentId:(NSNumber *)commentID placeHolderImage:(UIImage *)placeholderImage
{
    [VContentViewPresenter presentContentViewFromViewController:self.navigationController
                                          withDependencyManager:self.dependencyManager
                                                    ForSequence:sequence
                                                 inStreamWithID:streamId
                                                      commentID:commentID
                                               withPreviewImage:placeholderImage];
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
    if ( self.presentedViewController != nil )
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    if ( self.willSelectContainerViewController == nil )
    {
        for ( VNavigationDestinationContainerViewController *containerViewController in self.internalTabBarController.viewControllers )
        {
            if ( [containerViewController isKindOfClass:[VNavigationDestinationContainerViewController class]] )
            {
                const BOOL isViewControllerTabDestination = containerViewController.navigationDestination == (id<VNavigationDestination>)viewController;
                const BOOL isAlternateViewControllerTabDestination  = [containerViewController.navigationDestination respondsToSelector:@selector(alternateViewController)] &&
                viewController == [containerViewController.navigationDestination alternateViewController];
                
                if ( isAlternateViewControllerTabDestination || isViewControllerTabDestination )
                {
                    self.willSelectContainerViewController = containerViewController;
                    break;
                }
            }
        }
    }
    
    if (self.willSelectContainerViewController != nil)
    {
        VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
        if ( ![navigationController.innerNavigationController.viewControllers containsObject:viewController] )
        {
            if (self.willSelectContainerViewController.containedViewController == nil)
            {
                [navigationController.innerNavigationController pushViewController:viewController animated:NO];
                [self.willSelectContainerViewController setContainedViewController:navigationController];
            }
            [self.internalTabBarController setSelectedViewController:self.willSelectContainerViewController];
            [self setNeedsStatusBarAppearanceUpdate];
            self.willSelectContainerViewController = nil;
        }
    }
    else if ( [self.internalTabBarController.selectedViewController isKindOfClass:[VNavigationDestinationContainerViewController class]] )
    {
        VNavigationDestinationContainerViewController *containerViewController = (VNavigationDestinationContainerViewController *)self.internalTabBarController.selectedViewController;
        if ( [containerViewController.containedViewController isKindOfClass:[VNavigationController class]] )
        {
            VNavigationController *navigationController = (VNavigationController *)containerViewController.containedViewController;
            if ( ![navigationController.innerNavigationController.viewControllers containsObject:viewController] )
            {
                [navigationController.innerNavigationController pushViewController:viewController animated:animated];
            }
        }
    }
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

#pragma mark - VDeeplinkSupporter

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    return [[VContentDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager];
}

#pragma mark - Navigation

- (NSArray *)navigationDestinations
{
    return [self.internalTabBarController.viewControllers v_map:^id(VNavigationDestinationContainerViewController *container)
            {
                if ( [container isKindOfClass:[VNavigationDestinationContainerViewController class]] )
                {
                    return container.navigationDestination;
                }
                else
                {
                    return container;
                }
            }];
}

#pragma mark - First Launch Operations

- (void)setupFirstLaunchOperations
{
    if (self.hasSetupFirstLaunchOperations)
    {
        return;
    }
    self.hasSetupFirstLaunchOperations = YES;
    
    // Login
    [self queueLoginOperation];
    [self queueFirstTimeContentOperation];
    [self queuePushNotificationOperation];
    
    NSBlockOperation *allLaunchOperationFinishedBlockOperation = [NSBlockOperation blockOperationWithBlock:^
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            VLog(@"Enabling coachmarks");
            self.coachmarkManager.allowCoachmarks = YES;
        });
    }];
    [self.launchOperationQueue addOperation:allLaunchOperationFinishedBlockOperation];
}

- (void)queueLoginOperation
{
    AutoShowLoginOperation *loginOperation = [[AutoShowLoginOperation alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                                 dependencyManager:self.dependencyManager
                                                                       viewControllerToPresentFrom:self];
    self.loginOperation = loginOperation;
    [self.launchOperationQueue addOperation:loginOperation];
}

- (void)queueFirstTimeContentOperation
{
    NSDictionary *firstTimeContentConfiguration = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:kFirstTimeContentKey];
    VDependencyManager *firstTimeContentDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:firstTimeContentConfiguration];
    if (firstTimeContentConfiguration != nil)
    {
        FTUEVideoOperation *videoOperation = [[FTUEVideoOperation alloc] initWithDependencyManager:firstTimeContentDependencyManager
                                                                         viewControllerToPresentOn:self
                                                                                      sessionTimer:[VRootViewController rootViewController].sessionTimer];
        [self.launchOperationQueue addOperation:videoOperation];
    }
}

- (void)queuePushNotificationOperation
{
    RequestPushNotificationPermissionOperation *pushNotificationOperation = [[RequestPushNotificationPermissionOperation alloc] init];
    [self.launchOperationQueue addOperation:pushNotificationOperation];
}

#pragma mark - VRootViewControllerContainedViewController

- (void)onLoadingCompletion
{
    [self.loginOperation.loginAuthorizedAction execute];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(VNavigationDestinationContainerViewController *)viewController
{
    if (viewController == tabBarController.selectedViewController)
    {
        if ([viewController conformsToProtocol:@protocol(VTabMenuContainedViewControllerNavigation)])
        {
            [(id <VTabMenuContainedViewControllerNavigation>)viewController reselected];
        }
        return NO;
    }
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if ( index != NSNotFound )
    {
        [self.tabShim willNavigateToIndex:index];
    }
    
    self.willSelectContainerViewController = viewController;
    [self navigateToDestination:viewController.navigationDestination animated:YES];
    return NO;
}

@end
