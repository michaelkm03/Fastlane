//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAppDelegate.h"
#import "VForceUpgradeViewController.h"
#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VInboxContainerViewController.h"
#import "VLoadingViewController.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
#import "VScaffoldViewController.h"
#import "VSessionTimer.h"
#import "VSettingManager.h"
#import "VTracking.h"
#import "VConstants.h"
#import "VTemplateGenerator.h"
#import "VLocationManager.h"
#import "VVoteSettings.h"
#import "VVoteType.h"

static const NSTimeInterval kAnimationDuration = 0.2;

static NSString * const kDeeplinkURLKey = @"deeplink";
static NSString * const kNotificationIDKey = @"notification_id";

@interface VRootViewController () <VLoadingViewControllerDelegate>

#warning Temporary
@property (nonatomic, strong, readwrite) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VVoteSettings *voteSettings;
@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, strong) VSessionTimer *sessionTimer;
@property (nonatomic, strong) NSURL *queuedURL; ///< A deeplink URL that came in before we were ready for it
@property (nonatomic, strong) NSString *queuedNotificationID; ///< A notificationID that came in before we were ready for it
@property (nonatomic) BOOL appLaunched; ///< YES when VLoadingViewController has finished its job

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
    
    // Check if we have location services and start getting locations if we do
    if ( [VLocationManager haveLocationServicesPermission] )
    {
        [[VLocationManager sharedInstance].locationManager startUpdatingLocation];
    }
    
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
    self.appLaunched = NO;
    VLoadingViewController *loadingViewController = [VLoadingViewController loadingViewController];
    loadingViewController.delegate = self;
    [self showViewController:loadingViewController animated:NO completion:nil];
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
    self.sessionTimer.dependencyManager = self.dependencyManager;
    [self.sessionTimer start];
    
    self.voteSettings = [[VVoteSettings alloc] init];
    [self.voteSettings setVoteTypes:[self.dependencyManager voteTypes]];
    
    VScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    [self showViewController:scaffold animated:YES completion:^(void)
    {
        self.appLaunched = YES;
    }];
    
    if ( self.queuedURL != nil )
    {
        [scaffold navigateToDeeplinkURL:self.queuedURL];
        self.queuedURL = nil;
    }
}

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)(void))completion
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
        if ( completion != nil )
        {
            completion();
        }
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
    [self handlePushNotification:userInfo];
}

- (void)handlePushNotification:(NSDictionary *)pushNotification
{
    NSURL *deeplink = [NSURL URLWithString:pushNotification[kDeeplinkURLKey]];
    NSString *notificationID = pushNotification[kNotificationIDKey];

    if ( [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive )
    {
        [[VTrackingManager sharedInstance] setValue:notificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
        if ( [self.sessionTimer shouldNewSessionStartNow] )
        {
            self.queuedURL = deeplink;
            self.queuedNotificationID = notificationID;
        }
        else
        {
            [self handleDeeplinkURL:deeplink];
        }
    }
    else if ( [deeplink.host isEqualToString:VInboxContainerViewControllerDeeplinkHostComponent] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VInboxContainerViewControllerInboxPushReceivedNotification object:self];
    }
}

#pragma mark - NSNotifications

- (void)newSessionShouldStart:(NSNotification *)notification
{
    if ( !self.appLaunched )
    {
        return;
    }
    [[VTrackingManager sharedInstance] clearSessionParameters];
    
    if ( self.queuedNotificationID != nil )
    {
        [[VTrackingManager sharedInstance] setValue:self.queuedNotificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
        self.queuedNotificationID = nil;
    }
    
    [self showViewController:nil animated:NO completion:nil];
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
    if ( loadingViewController == self.currentViewController )
    {
        [self startAppWithInitData:initResponse];
    }
}

@end
