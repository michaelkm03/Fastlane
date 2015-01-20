//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAppDelegate.h"
#import "VForceUpgradeViewController.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VObjectManager.h"
#import "VLoadingViewController.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
#import "VScaffoldViewController.h"
#import "VSessionTimer.h"
#import "VConstants.h"
#import "VTemplateGenerator.h"

static const NSTimeInterval kAnimationDuration = 0.2;

@interface VRootViewController () <VLoadingViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, strong) VSessionTimer *sessionTimer;
@property (nonatomic, strong) NSURL *queuedURL; ///< A deeplink URL that came in before we were ready for it

@end

@implementation VRootViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSessionShouldStart:) name:VSessionTimerNewSessionShouldStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+ (instancetype)rootViewController
{
    VRootViewController *rootViewController = (VRootViewController *)[[(VAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
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

    self.sessionTimer = [[VSessionTimer alloc] init];
    [self.sessionTimer start];
    
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
    loadingViewController.delegate = self;
    [self showViewController:loadingViewController animated:NO];
}

- (void)startAppWithInitData:(NSDictionary *)initData
{
    VDependencyManager *basicDependencies = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:@{ VDependencyManagerObjectManagerKey:[VObjectManager sharedManager] }
                                                            dictionaryOfClassesByTemplateName:nil];
    
    VTemplateGenerator *templateGenerator = [[VTemplateGenerator alloc] initWithInitData:initData];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:basicDependencies
                                                                 configuration:[templateGenerator configurationDict]
                                             dictionaryOfClassesByTemplateName:nil];
    
    VScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    [self showViewController:scaffold animated:YES];
    
    if ( self.queuedURL != nil )
    {
        [scaffold navigateToDeeplinkURL:self.queuedURL];
        self.queuedURL = nil;
    }
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

#pragma mark - Deeplink

- (void)handleDeeplinkURL:(NSURL *)url
{
    VScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    
    if ( scaffold == nil )
    {
        self.queuedURL = url;
    }
    else
    {
        [scaffold navigateToDeeplinkURL:url];
    }
}

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ( [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive )
    {
        [self handlePushNotification:userInfo];
    }
}

- (void)handlePushNotification:(NSDictionary *)pushNotification
{
    NSURL *deeplink = [NSURL URLWithString:pushNotification[@"deeplink"]];
    if ( deeplink != nil )
    {
        [self handleDeeplinkURL:deeplink];
    }
}

#pragma mark - NSNotifications

- (void)newSessionShouldStart:(NSNotification *)notification
{
    [self showViewController:nil animated:NO];
    [RKObjectManager setSharedManager:nil];
    [VObjectManager setupObjectManager];
    [self showLoadingViewController];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSURL *url = notification.userInfo[UIApplicationLaunchOptionsURLKey];
    if ( url != nil )
    {
        [self handleDeeplinkURL:url];
        return;
    }
    
    NSDictionary *pushNotification = notification.userInfo[UIApplicationLaunchOptionsRemoteNotificationKey];
    if ( pushNotification != nil )
    {
        [self handlePushNotification:pushNotification];
        return;
    }
}

#pragma mark - VLoadingViewControllerDelegate

- (void)loadingViewController:(VLoadingViewController *)loadingViewController didFinishLoadingWithInitResponse:(NSDictionary *)initResponse
{
    [self startAppWithInitData:initResponse];
}

@end
