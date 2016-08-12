//
//  VRootViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VDefaultTemplate.h"
#import "VDependencyManager+NavigationBar.h"
#import "VLoadingViewController.h"
#import "VRootViewController.h"
#import "VSessionTimer.h"
#import "VThemeManager.h"
#import "VConstants.h"
#import "VAppInfo.h"
#import "VUploadManager.h"
#import "VApplicationTracking.h"
#import "VEnvironment.h"
#import "victorious-Swift.h"
#import "VCrashlyticsLogTracking.h"

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

@interface VRootViewController () <VLoadingViewControllerDelegate>

@property (nonatomic, strong) VDependencyManager *rootDependencyManager; ///< The dependency manager at the top of the heirarchy--the one with no parent
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, strong) VLoadingViewController *loadingViewController;
@property (nonatomic, strong, readwrite) VSessionTimer *sessionTimer;
@property (nonatomic, strong) NSString *queuedNotificationID; ///< A notificationID that came in before we were ready for it
@property (nonatomic) VAppLaunchState launchState; ///< At what point in the launch lifecycle are we?
@property (nonatomic) BOOL properlyBackgrounded; ///< The app has been properly sent to the background (not merely lost focus)
@property (nonatomic, strong) VApplicationTracking *applicationTracking;
@property (nonatomic, strong) VCrashlyticsLogTracking *crashlyticsLogTracking;
@property (nonatomic, strong) NSURL *queuedDeeplink;
@property (nonatomic, strong, readwrite) UIViewController<Scaffold> *scaffold;

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
    self.applicationTracking = [[VApplicationTracking alloc] init];
    self.crashlyticsLogTracking = [[VCrashlyticsLogTracking alloc] init];
    [[VTrackingManager sharedInstance] addDelegate:self.applicationTracking];
    [[VTrackingManager sharedInstance] addDelegate:self.crashlyticsLogTracking];

    self.sessionTimer = [[VSessionTimer alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSessionShouldStart:) name:VSessionTimerNewSessionShouldStart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

+ (instancetype)sharedRootViewController
{
    VRootViewController *rootViewController = (VRootViewController *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
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
    [self showLoadingViewController];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
                                                                                configuration:nil
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

/** This function assumes `self.dependencyManager` has been set. So make sure
 we call it after loading finishes
 */
- (void)initialSetupAfterLoading
{
    NSAssert(self.dependencyManager != nil, @"We need a valid dependency manager to perform initial setup");
    self.sessionTimer.dependencyManager = self.dependencyManager;
    [self.sessionTimer start];
    [[VThemeManager sharedThemeManager] setDependencyManager:self.dependencyManager];
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    NSURL *appStoreURL = appInfo.appURL;
    if ( appStoreURL != nil )
    {
        [[NSUserDefaults standardUserDefaults] setObject:appStoreURL.absoluteString forKey:VConstantAppStoreURL];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /// Body removed alongside FetchTemplateProductIdentifiersOperation
    
    [[InterstitialManager sharedInstance] setDependencyManager:self.dependencyManager];
}

- (void)showLogin
{
    ShowLoginOperation *showLoginOperation = [[ShowLoginOperation alloc] initWithOriginViewController:self
                                                                                    dependencyManager:[self.dependencyManager childDependencyForKey:VDependencyManagerScaffoldViewControllerKey]
                                                                                             animated:NO
                                                                                      loginCompletion:^{
                                                                                          [self initializeScaffold];
                                                                                      }];
    
    [showLoginOperation queueWithCompletion:nil];
}

- (void)initializeScaffold
{
    self.applicationTracking.dependencyManager = self.dependencyManager;
    [DefaultTimingTracker sharedInstance].dependencyManager = self.dependencyManager;
    
    UIViewController<Scaffold> *scaffold = [self.dependencyManager scaffoldViewController];
    self.scaffold = scaffold;
    
    [self showViewController:scaffold animated:YES completion:^(void)
    {
        self.launchState = VAppLaunchStateLaunched;
        
        if (self.queuedDeeplink != nil)
        {
            [self showDeeplink:self.queuedDeeplink on:scaffold];
            self.queuedDeeplink = nil;
        }
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
            viewController.view.alpha = 0;
            [UIView animateWithDuration:kAnimationDuration
                                  delay:0.0f
                 usingSpringWithDamping:1.0f
                  initialSpringVelocity:0.0f
                                options:kNilOptions
                             animations:^(void)
             {
                 viewController.view.alpha = 1;
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
    
    if ( notificationID != nil )
    {
        [[VTrackingManager sharedInstance] setValue:notificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
    }
    
    if (deepLink != nil)
    {
        [self openURL:deepLink fromExternalSourceWithOptionalNotificationID:notificationID];
    }
}

- (void)applicationOpenURL:(NSURL *)url
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
        if ( [self.sessionTimer shouldNewSessionStartNow] )
        {
            self.queuedDeeplink = deepLink;
            self.queuedNotificationID = notificationID;
        }
        else
        {
            [self openURL:deepLink];
        }
    }
}

- (void)openURL:(NSURL *)url
{
    if (self.scaffold == nil)
    {
        self.queuedDeeplink = url;
    }
    else
    {
        [self showDeeplink:url on:self.scaffold];
    }
}

- (void)startNewSession
{
    [self newSessionShouldStart:nil];
}

#pragma mark - NSNotifications

- (void)newSessionShouldStart:(NSNotification *)notification
{
    if ( self.launchState == VAppLaunchStateLaunching )
    {
        return;
    }
    
    if ( self.queuedNotificationID != nil )
    {
        [[VTrackingManager sharedInstance] setValue:self.queuedNotificationID forSessionParameterWithKey:VTrackingKeyNotificationId];
        self.queuedNotificationID = nil;
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
    self.dependencyManager = dependencyManager;
    
    if ( loadingViewController == self.currentViewController && self.launchState == VAppLaunchStateWaiting )
    {
        self.launchState = VAppLaunchStateLaunching;
        [self showLogin];
    }
    
    [self initialSetupAfterLoading];
}

@end
