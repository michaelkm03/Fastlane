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
#import "VContentViewFactory.h"
#import "VNavigationDestinationContainerViewController.h"
#import "VNavigationController.h"
#import "VDependencyManager+VStatusBarStyle.h"
#import "VObjectManager+Login.h"

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
#import "VCoachmarkDisplayResponder.h"

// Etc
#import "NSArray+VMap.h"
#import "NSURL+VPathHelper.h"

// Swift Module
#import "victorious-Swift.h"

static NSString * const kMenuKey = @"menu";
static NSString * const kFirstTimeContentKey = @"firstTimeContent";

@interface VTabScaffoldViewController () <UITabBarControllerDelegate, VDeeplinkHandler, VDeeplinkSupporter, VCoachmarkDisplayResponder, AutoShowLoginOperationDelegate, InterstitialListener>

@property (nonatomic, strong) VNavigationController *rootNavigationController;
@property (nonatomic, strong) UITabBarController *internalTabBarController;
@property (nonatomic, strong) VNavigationDestinationContainerViewController *willSelectContainerViewController;

@property (nonatomic, strong) VTabMenuShim *tabShim;
@property (nonatomic, strong) VTabScaffoldHidingHelper *hidingHelper;
@property (nonatomic, strong) NSOperationQueue *launchOperationQueue;
@property (nonatomic, weak) AutoShowLoginOperation *loginOperation;
@property (nonatomic, assign) BOOL hasSetupFirstLaunchOperations;

@property (nonatomic, strong) UIViewController *autoShowLoginViewController;
@property (nonatomic, strong) ContentViewPresenter *contentViewPresenter;

@end

@implementation VTabScaffoldViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:nil bundle:nil];
    if ( self != nil )
    {
        _rootNavigationController = [[VNavigationController alloc] init];
        _dependencyManager = dependencyManager;
        _coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:_dependencyManager];
        _launchOperationQueue = [[NSOperationQueue alloc] init];
        _launchOperationQueue.maxConcurrentOperationCount = 1;
        _hasSetupFirstLaunchOperations = NO;
        _contentViewPresenter = [[ContentViewPresenter alloc] init];
    }
    return self;
}

- (UITabBarController *)tabBarController
{
    return self.internalTabBarController;
}

- (void)dealloc
{
    _internalTabBarController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.rootNavigationController.innerNavigationController.navigationBar.translucent = NO;
    [self.dependencyManager applyStyleToNavigationBar:self.rootNavigationController.innerNavigationController.navigationBar];
    [self.view addSubview:self.rootNavigationController.view];
    [self.view v_addFitToParentConstraintsToSubview:self.rootNavigationController.view];
    [self.rootNavigationController didMoveToParentViewController:self];
    
#warning this is temporary
//    if ([VObjectManager sharedManager].mainUserLoggedIn)
//    {
        [self configureTabBar];
//    }
    
    // Make sure we're listening for interstitial events
    [[InterstitialManager sharedInstance] setInterstitialListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoggedInChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification)
     {
         if (![VObjectManager sharedManager].mainUserLoggedIn)
         {
             VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                                  dependencyManager:self.dependencyManager];
             [authorizedAction performFromViewController: self.rootNavigationController.innerNavigationController.visibleViewController
                                                 context:VAuthorizationContextDefault
                                              completion:^(BOOL authorized) { }];
         }
     }];
}

- (void)configureTabBar
{
    self.internalTabBarController = [[NavigationBarHiddenTabViewController alloc] init];
    self.internalTabBarController.delegate = self;
    self.tabShim = [self.dependencyManager templateValueOfType:[VTabMenuShim class] forKey:kMenuKey];
    [self.internalTabBarController.tabBar setTintColor:self.tabShim.selectedIconColor];
    self.internalTabBarController.viewControllers = [self.tabShim wrappedNavigationDesinations];
    self.hidingHelper = [[VTabScaffoldHidingHelper alloc] initWithTabBar:self.internalTabBarController.tabBar];

    VBackground *backgroundForTabBar = self.tabShim.background;
    if ([backgroundForTabBar isKindOfClass:[VSolidColorBackground class]])
    {
        VSolidColorBackground *solidColorBackground = (VSolidColorBackground *)backgroundForTabBar;
        self.internalTabBarController.tabBar.translucent = NO;
        self.internalTabBarController.tabBar.barTintColor = solidColorBackground.backgroundColor;
    }
    
    [self.rootNavigationController.innerNavigationController pushViewController:self.internalTabBarController animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( ![AgeGate isAnonymousUser] )
    {
        [self setupFirstLaunchOperations];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.presentedViewController == nil)
    {
        [[InterstitialManager sharedInstance] displayNextInterstitialIfPossible:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIColor *navigationBarTextColor = [[self.dependencyManager dependencyManagerForNavigationBar] colorForKey:VDependencyManagerMainTextColorKey];
    return [StatusBarUtilities statusBarStyleWithColor:navigationBarTextColor];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if (self.autoShowLoginViewController != nil)
    {
        return self.autoShowLoginViewController;
    }
    else
    {
        return self.internalTabBarController;
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if (self.autoShowLoginViewController != nil)
    {
        return self.autoShowLoginViewController;
    }
    else
    {
        return self.internalTabBarController;
    }
}

#pragma mark - Public API

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
    loginOperation.delegate = self;
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

#pragma mark - AutoShowLoginOperationDelegate

- (void)showLoginViewController:(UIViewController *__nonnull)loginViewController
{
    [self addChildViewController:loginViewController];
    [self.view addSubview:loginViewController.view];
    [self.view v_addFitToParentConstraintsToSubview:loginViewController.view];
    [loginViewController didMoveToParentViewController:self];
    self.autoShowLoginViewController = loginViewController;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)hideLoginViewController:(void (^ __nonnull)(void))completion
{
    [self configureTabBar];
    [self.autoShowLoginViewController willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         CGFloat yTranslationAmount = CGRectGetHeight(self.autoShowLoginViewController.view.bounds);
         self.autoShowLoginViewController.view.transform = CGAffineTransformMakeTranslation(0, yTranslationAmount);
     }
                     completion:^(BOOL finished)
     {
         [self.autoShowLoginViewController.view removeFromSuperview];
         [self.autoShowLoginViewController removeFromParentViewController];
         self.autoShowLoginViewController = nil;
         [self setNeedsStatusBarAppearanceUpdate];
         completion();
     }];
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

#pragma mark - VDeeplinkSupporter

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    id<VDeeplinkHandler> contentDeeplinkHandler = [[VContentDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager];
    if ( [contentDeeplinkHandler canDisplayContentForDeeplinkURL:url] )
    {
        return contentDeeplinkHandler;
    }
    return (id<VDeeplinkHandler>)self;
}

#pragma mark - VDeeplinkHandler

- (BOOL)requiresAuthorization
{
    return NO;
}

- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( [self canDisplayContentForDeeplinkURL:url] )
    {
        NSInteger index = [[url v_firstNonSlashPathComponent] integerValue];
        UIViewController *viewController = self.internalTabBarController.viewControllers[ index ];
        [self.internalTabBarController setSelectedViewController:viewController];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    const BOOL isHostValid = [url.host isEqualToString:kMenuKey];
    NSString *pathComponent = [url v_firstNonSlashPathComponent];
    if ( pathComponent == nil )
    {
        return NO;
    }
    const NSInteger index = [pathComponent integerValue];
    const BOOL isSectionValid = index >= 0 && index < (NSInteger)self.internalTabBarController.viewControllers.count;
    return isHostValid && isSectionValid;
}

#pragma mark - VCoachmarkDisplayResponder

- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion
{
    for ( NSUInteger index = 0; index < self.navigationDestinations.count; index++ )
    {
        UIViewController *viewController = self.navigationDestinations[index];
        if ( [viewController conformsToProtocol:@protocol(VCoachmarkDisplayer)] )
        {
            UIViewController <VCoachmarkDisplayer> *coachmarkDisplayer = (UIViewController <VCoachmarkDisplayer> *)viewController;
            
            //View controller can display a coachmark
            NSString *screenIdenifier = [coachmarkDisplayer screenIdentifier];
            if ( [identifier isEqualToString:screenIdenifier] )
            {
                //Found the screen that we're supposed to point out
                CGRect frame = self.internalTabBarController.tabBar.frame;
                CGFloat width = CGRectGetWidth(frame) / self.internalTabBarController.tabBar.items.count;
                frame.size.width = width;
                frame.origin.x = width * index;
                completion(YES, frame);
                return;
            }
        }
    }
    
    UIResponder <VCoachmarkDisplayResponder> *nextResponder = [self.nextResponder targetForAction:@selector(findOnScreenMenuItemWithIdentifier:andCompletion:) withSender:nil];
    if ( nextResponder == nil )
    {
        completion(NO, CGRectZero);
    }
    else
    {
        [nextResponder findOnScreenMenuItemWithIdentifier:identifier andCompletion:completion];
    }
}

#pragma mark - Interstitial Listener

- (void)newInterstitialHasBeenRegistered
{
    if (self.presentedViewController == nil)
    {
        [[InterstitialManager sharedInstance] displayNextInterstitialIfPossible:self];
    }
}

@end
