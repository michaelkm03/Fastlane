//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAdViewController.h"
#import "VAppDelegate.h"
#import "VForceUpgradeViewController.h"
#import "VDependencyManager+VDefaultTemplate.h"
#import "VDependencyManager+VObjectManager.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VInboxViewController.h"
#import "VLoadingViewController.h"
#import "VObjectManager.h"
#import "VRootViewController.h"
#import "VTabScaffoldViewController.h"
#import "VSessionTimer.h"
#import "VThemeManager.h"
#import "VTracking.h"
#import "TremorVideoAd.h"
#import "VConstants.h"
#import "VLocationManager.h"
#import "VVoteSettings.h"
#import "VVoteType.h"
#import "VAppInfo.h"
#import "VUploadManager.h"
#import "VApplicationTracking.h"
#import "VEnvironment.h"
#import "VFollowingHelper.h"
#import "VHashtagHelper.h"
#import "VHashtagResponder.h"
#import "VFollowResponder.h"
#import "VURLSelectionResponder.h"

NSString * const VApplicationDidBecomeActiveNotification = @"VApplicationDidBecomeActiveNotification";

static const NSTimeInterval kAnimationDuration = 0.25f;

static NSString * const kDeepLinkURLKey = @"deeplink";
static NSString * const kNotificationIDKey = @"notification_id";
static NSString * const kAdSystemsKey = @"ad_systems";

typedef NS_ENUM(NSInteger, VAppLaunchState)
{
    VAppLaunchStateWaiting, ///< The app is waiting for a response from the server
    VAppLaunchStateLaunching, ///< The app has received its initial data from the server and is waiting for the scaffold to be displayed
    VAppLaunchStateLaunched ///< The scaffold is displayed and we're fully launched
};

@interface VRootViewController () <VLoadingViewControllerDelegate, VURLSelectionResponder, VFollowResponder, VHashtagResponder>

@property (nonatomic, strong) VDependencyManager *rootDependencyManager; ///< The dependency manager at the top of the heirarchy--the one with no parent
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VVoteSettings *voteSettings;
@property (nonatomic) BOOL appearing;
@property (nonatomic) BOOL shouldPresentForceUpgradeScreenOnNextAppearance;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, strong) VLoadingViewController *loadingViewController;
@property (nonatomic, strong, readwrite) VSessionTimer *sessionTimer;
@property (nonatomic, strong) NSString *queuedNotificationID; ///< A notificationID that came in before we were ready for it
@property (nonatomic) VAppLaunchState launchState; ///< At what point in the launch lifecycle are we?
@property (nonatomic) BOOL properlyBackgrounded; ///< The app has been properly sent to the background (not merely lost focus)
@property (nonatomic, strong) VDeeplinkReceiver *deepLinkReceiver;
@property (nonatomic, strong) VApplicationTracking *applicationTracking;
@property (nonatomic, strong) VFollowingHelper *followHelper;
@property (nonatomic, strong) VHashtagHelper *hashtagHelper;

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
    self.deepLinkReceiver = [[VDeeplinkReceiver alloc] init];
    self.applicationTracking = [[VApplicationTracking alloc] init];
    [[VTrackingManager sharedInstance] addDelegate:self.applicationTracking];
    
    self.sessionTimer = [[VSessionTimer alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSessionShouldStart:) name:VSessionTimerNewSessionShouldStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
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

- (VDependencyManager *)createNewParentDependencyManager
{
    if ( self.rootDependencyManager != nil )
    {
        [self.rootDependencyManager cleanup];
        self.rootDependencyManager = nil;
    }
    
    self.rootDependencyManager = [VDependencyManager dependencyManagerWithDefaultValuesForColorsAndFonts];
    VDependencyManager *basicDependencies = [[VDependencyManager alloc] initWithParentManager:self.rootDependencyManager
                                                                                configuration:@{ VDependencyManagerObjectManagerKey:[VObjectManager sharedManager] }
                                                            dictionaryOfClassesByTemplateName:nil];
    return basicDependencies;
}

- (void)showLoadingViewController
{
    self.launchState = VAppLaunchStateWaiting;
    self.loadingViewController = [VLoadingViewController loadingViewController];
    self.loadingViewController.delegate = self;
    self.loadingViewController.parentDependencyManager = [self createNewParentDependencyManager];
    [self showViewController:self.loadingViewController animated:NO completion:nil];
}

- (void)startAppWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self.dependencyManager = dependencyManager;
    self.applicationTracking.dependencyManager = dependencyManager;
    
    VTabScaffoldViewController *scaffold = [self.dependencyManager scaffoldViewController];
    // Initialize followHelper with scaffold.dependencyManager so that it knows about LoginFlow information
    // This is a result of the refactor of FollowResponder protocol (VRootViewController is the actual responder
    // for follow actions)
    self.followHelper = [[VFollowingHelper alloc] initWithDependencyManager:scaffold.dependencyManager viewControllerToPresentOn:self];
    self.hashtagHelper = [[VHashtagHelper alloc] init];
    
    NSDictionary *scaffoldConfig = [dependencyManager templateValueOfType:[NSDictionary class] forKey:VDependencyManagerScaffoldViewControllerKey];
    self.deepLinkReceiver.dependencyManager = [dependencyManager childDependencyManagerWithAddedConfiguration:scaffoldConfig];
    
    [self seedMonetizationNetworks:[dependencyManager templateValueOfType:[NSArray class] forKey:kAdSystemsKey]];
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    self.sessionTimer.dependencyManager = self.dependencyManager;
    [[VThemeManager sharedThemeManager] setDependencyManager:self.dependencyManager];
    [self.sessionTimer start];
    
    self.voteSettings = [[VVoteSettings alloc] init];
    [self.voteSettings setVoteTypes:[self.dependencyManager voteTypes]];
    
    NSURL *appStoreURL = appInfo.appURL;
    if ( appStoreURL != nil )
    {
        [[NSUserDefaults standardUserDefaults] setObject:appStoreURL.absoluteString forKey:VConstantAppStoreURL];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self showViewController:scaffold animated:YES completion:^(void)
    {
        self.launchState = VAppLaunchStateLaunched;
        
        // VDeeplinkReceiver depends on scaffold being visible already, so make sure this is in this completion block
        [self.deepLinkReceiver receiveQueuedDeeplink];
    }];
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
            if ([viewController conformsToProtocol:@protocol(VRootViewControllerContainedViewController) ])
            {
                [((id<VRootViewControllerContainedViewController>)viewController) onLoadingCompletion];
            }
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            finishingTasks();
        };
        
        if (animated)
        {
            viewController.view.clipsToBounds = YES;
            viewController.view.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 1.5f, CGRectGetMidY(self.view.bounds));
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0f
                 usingSpringWithDamping:1.0f
                  initialSpringVelocity:0.0f
                                options:kNilOptions
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

- (void)applicationDidReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handlePushNotification:userInfo];
}

- (void)handlePushNotification:(NSDictionary *)pushNotification
{
    NSURL *deepLink = [NSURL URLWithString:pushNotification[kDeepLinkURLKey]];
    NSString *notificationID = pushNotification[kNotificationIDKey];
    if (deepLink != nil)
    {
        [self openURL:deepLink fromExternalSourceWithOptionalNotificationID:notificationID];
    }
}

- (void)applicationOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self openURL:url fromExternalSourceWithOptionalNotificationID:nil];
}

/**
 This version of -openURL: should be called when the request to open a URL comes from a place outside of the app, usually
 a push notification, but maybe mobile safari or another application calling -[UIApplication openURL:]
 */
- (void)openURL:(NSURL *)deepLink fromExternalSourceWithOptionalNotificationID:(NSString *)notificationID
{
    if ( [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive && self.properlyBackgrounded )
    {
        if ( notificationID != nil )
        {
            [[VTrackingManager sharedInstance] setValue:notificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
        }
        if ( [self.sessionTimer shouldNewSessionStartNow] )
        {
            [self.deepLinkReceiver queueDeeplink:deepLink];
            self.queuedNotificationID = notificationID;
        }
        else
        {
            [self openURL:deepLink];
        }
    }
    else if ( [deepLink.host isEqualToString:VInboxViewControllerDeeplinkHostComponent] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VInboxViewControllerInboxPushReceivedNotification object:self];
    }
}

- (void)openURL:(NSURL *)url
{
    [self.deepLinkReceiver receiveDeeplink:url];
}

#pragma mark - Ad Networks

- (void)seedMonetizationNetworks:(NSArray *)adSystems
{
    if (adSystems)
    {
        NSUInteger i;
        NSString *appID;
        
        for (i = 0; i < adSystems.count; i++)
        {
            NSDictionary *item = adSystems[i];
            NSInteger adSystem = [[item valueForKey:@"ad_system"] integerValue];
            
            switch (adSystem)
            {
                case VMonetizationPartnerTremor:
                    appID = [item valueForKey:@"tremor_app_id"];
                    
                    // If we have an appID, seed the Tremor Ad Network
                    if (appID && (appID != nil && ![appID isKindOfClass:[NSNull class]]))
                    {
                        [TremorVideoAd initWithAppID:appID];
                        [TremorVideoAd start];
                    }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

#pragma mark - NSNotifications

- (void)newSessionShouldStart:(NSNotification *)notification
{
    if ( self.launchState == VAppLaunchStateLaunching )
    {
        return;
    }
    
#ifdef V_SWITCH_ENVIRONMENTS
    NSNumber *environmentError = notification.userInfo[ VEnvironmentDidFailToLoad ];
    if ( environmentError.boolValue )
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Environment Error" message:@"Error while launching on custom environment.\nReverting back to default." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
        {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [self presentViewController:alert animated:YES completion:nil];
                       });
    }
#endif
    
    if ( self.queuedNotificationID != nil )
    {
        [[VTrackingManager sharedInstance] setValue:self.queuedNotificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
        self.queuedNotificationID = nil;
    }
    
    [self showViewController:nil animated:NO completion:nil];
    [RKObjectManager setSharedManager:nil];
    [VObjectManager setupObjectManagerWithUploadManager:[VUploadManager sharedManager]];
    [self showLoadingViewController];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.properlyBackgrounded = YES;
    
    NSURL *url = notification.userInfo[UIApplicationLaunchOptionsURLKey];
    if ( url != nil )
    {
        [self openURL:url];
        return;
    }
    
    NSDictionary *pushNotification = notification.userInfo[UIApplicationLaunchOptionsRemoteNotificationKey];
    if ( pushNotification != nil )
    {
        [self handlePushNotification:pushNotification];
        return;
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.properlyBackgrounded = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    self.properlyBackgrounded = NO;
}

#pragma mark - VLoadingViewControllerDelegate

- (void)loadingViewController:(VLoadingViewController *)loadingViewController didFinishLoadingWithDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( loadingViewController == self.currentViewController && self.launchState == VAppLaunchStateWaiting )
    {
        self.launchState = VAppLaunchStateLaunching;
        [self startAppWithDependencyManager:dependencyManager];
    }
}

#pragma mark - VFollowResponder

- (void)followUser:(VUser *)user withAuthorizedBlock:(void (^)(void))authorizedBlock andCompletion:(VFollowHelperCompletion)completion fromViewController:(UIViewController *)viewControllerToPresentOn withScreenName:(NSString *)screenName
{
    UIViewController *sourceViewController = viewControllerToPresentOn?:self;
    
    [self.followHelper followUser:user
              withAuthorizedBlock:authorizedBlock
                    andCompletion:completion
               fromViewController:sourceViewController
                   withScreenName:screenName];
}

- (void)unfollowUser:(VUser *)user
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowHelperCompletion)completion
{
    [self.followHelper unfollowUser:user
                withAuthorizedBlock:authorizedBlock
                      andCompletion:completion];
}

#pragma mark - VHashtag

- (void)followHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
{
    [self.hashtagHelper followHashtag:hashtag successBlock:success failureBlock:failure];
}

- (void)unfollowHashtag:(NSString *)hashtag successBlock:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *))failure
{
    [self.hashtagHelper unfollowHashtag:hashtag successBlock:success failureBlock:failure];
}

#pragma mark - VURLSelectionResponder

- (void)URLSelected:(NSURL *)URL
{
    [[self.dependencyManager scaffoldViewController] showWebBrowserWithURL:URL];
}

@end
