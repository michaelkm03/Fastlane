//
//  VModernLoginAndRegistrationFlowViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLoginAndRegistrationFlowViewController.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VDependencyManager+VStatusBarStyle.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "UIAlertController+VSimpleAlert.h"
#import "VBackgroundContainer.h"
#import "VLoginFlowAPIHelper.h"
#import "VModernResetTokenViewController.h"
#import "VModernFlowControllerAnimationController.h"
#import "VEnterProfilePictureCameraViewController.h"
#import "VLoginFlowControllerDelegate.h"
#import "VPermissionsTrackingHelper.h"
#import "victorious-Swift.h"
#import "VSocialLoginErrors.h"

@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import MBProgressHUD;
@import VictoriousIOSSDK;

static NSString * const kRegistrationScreens = @"registrationScreens";
static NSString * const kLoginScreens = @"loginScreens";
static NSString * const kLandingScreen = @"landingScreen";
static NSString * const kLoadingScreen = @"loadingScreen";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernLoginAndRegistrationFlowViewController () <VLoginFlowControllerDelegate, VBackgroundContainer, UINavigationControllerDelegate, UIGestureRecognizerDelegate, LoginLoadingScreenDelegate>

@property (nonatomic, strong) VModernFlowControllerAnimationController *animator;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteraction;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *popGestureRecognizer;

@property (nonatomic, strong) UIViewController<VLoginFlowScreen> *landingScreen;
@property (nonatomic, strong) UIViewController<VLoginFlowScreen> *currentScreen;
@property (nonatomic, strong) UIViewController<LoginFlowLoadingScreen> *loadingScreen;
@property (nonatomic, strong) NSArray *registrationScreens;
@property (nonatomic, strong) NSArray *loginScreens;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@property (nonatomic, assign) BOOL hasShownInitial;
@property (nonatomic, strong) VLoginFlowAPIHelper *loginFlowHelper;
@property (nonatomic, strong) MBProgressHUD *facebookLoginProgressHUD;

@property (nonatomic, strong) NSOperation *currentOperation;
@property (nonatomic, copy) void (^onLoadingAppeared)();
@property (nonatomic, strong) DefaultTimingTracker *appTimingTracker;

@end

@implementation VModernLoginAndRegistrationFlowViewController

@synthesize onCompletionBlock;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        // Landing
        _landingScreen = [dependencyManager templateValueOfType:[UIViewController class]
                                                         forKey:kLandingScreen];
        _loadingScreen = [dependencyManager templateValueConformingToProtocol:@protocol(LoginFlowLoadingScreen) forKey:kLoadingScreen];
        _loadingScreen.loadingScreenDelegate = self;
        
        [self setDelegateForScreensInArray:@[_landingScreen]];
        [self setViewControllers:@[_landingScreen]];
        
        // Login + Registration
        _registrationScreens = [dependencyManager arrayOfValuesConformingToProtocol:@protocol(VLoginFlowScreen)
                                                                             forKey:kRegistrationScreens];
        [self setDelegateForScreensInArray:_registrationScreens];
        
        _loginScreens = [dependencyManager arrayOfValuesConformingToProtocol:@protocol(VLoginFlowScreen)
                                                                      forKey:kLoginScreens];
        [self setDelegateForScreensInArray:_loginScreens];
        
        _loginFlowHelper = [[VLoginFlowAPIHelper alloc] initWithViewControllerToPresentOn:self
                                                                        dependencyManager:dependencyManager];
        
        _animator = [[VModernFlowControllerAnimationController alloc] init];
        _percentDrivenInteraction = [[UIPercentDrivenInteractiveTransition alloc] init];
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
        
        _appTimingTracker = [DefaultTimingTracker sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer *backGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromLeftSideOfScreen:)];
    backGesture.delegate = self;
    backGesture.edges = UIRectEdgeLeft;
    self.popGestureRecognizer = backGesture;
    [self.view addGestureRecognizer:backGesture];
    
    self.delegate = self;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationBar.translucent = YES;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.tintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.actionsDisabled = NO;
    
    if ( self.isBeingPresented )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidStartRegistration];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ( self.isBeingDismissed )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFinishRegistration];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.dependencyManager statusBarStyleForKey:kStatusBarStyleKey];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setDelegateForScreensInArray:(NSArray *)array
{
    for ( id<VLoginFlowScreen> screen in array )
    {
        if ( [screen conformsToProtocol:@protocol(VLoginFlowScreen)] )
        {
            screen.delegate = self;
        }
    }
}

- (void)registrationDidFinishedWithSuccess:(BOOL)success
{
    if ( self.onCompletionBlock != nil )
    {
        self.onCompletionBlock( success );
    }
    
    if ( self.isRegisteredAsNewUser )
    {
        [self.appTimingTracker endEventWithType:VAppTimingEventTypeSignup subtype:nil];
        [self.appTimingTracker resetEventWithType:VAppTimingEventTypeLogin];
    }
    else
    {
        [self.appTimingTracker endEventWithType:VAppTimingEventTypeLogin subtype:nil];
        [self.appTimingTracker resetEventWithType:VAppTimingEventTypeSignup];
    }
}

#pragma mark - Gesture Target

- (void)pannedFromLeftSideOfScreen:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            if (!self.topViewController.navigationItem.hidesBackButton)
            {
                [self popViewControllerAnimated:YES];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat percentThrough = (translation.x / CGRectGetWidth(self.view.bounds));
            [self.percentDrivenInteraction updateInteractiveTransition:percentThrough];
        }
            break;
        case UIGestureRecognizerStateEnded:
            if ([gestureRecognizer velocityInView:gestureRecognizer.view].x > 0)
            {
                [self.percentDrivenInteraction finishInteractiveTransition];
            }
            else
            {
                [self.percentDrivenInteraction cancelInteractiveTransition];
            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            break;
    }
}

#pragma mark - VLoginFlowControllerDelegate

- (BOOL)isFinalRegistrationScreen:(UIViewController *)viewController
{
    return [[self.registrationScreens lastObject] isEqual:viewController];
}
- (void)selectedLogin
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeLogin];
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeSignup];
    
    [self.appTimingTracker startEventWithType:VAppTimingEventTypeLogin subtype:VAppTimingEventSubtypeEmail];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLoginWithEmail];
    
    UIViewController<VLoginFlowScreen> *firstLoginScreen = [self.loginScreens firstObject];
    self.currentScreen = firstLoginScreen;
    [self pushViewController:firstLoginScreen animated:YES];
}

- (void)selectedRegister
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeLogin];
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeSignup];
    
    [self.appTimingTracker startEventWithType:VAppTimingEventTypeLogin subtype:VAppTimingEventSubtypeEmail];
    [self.appTimingTracker startEventWithType:VAppTimingEventTypeSignup subtype:VAppTimingEventSubtypeEmail];
    
    UIViewController<VLoginFlowScreen> *firstRegistrationScreen = [self.registrationScreens firstObject];
    self.currentScreen = firstRegistrationScreen;
    [self pushViewController:firstRegistrationScreen animated:YES];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignupWithEmail];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)showAlertErrorWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [self loginErrorAlertAcknowledged];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectedFacebookAuthorization
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeLogin];
    [self.appTimingTracker resetAllEventsWithType:VAppTimingEventTypeSignup];
    
    [self.appTimingTracker startEventWithType:VAppTimingEventTypeSignup subtype:VAppTimingEventSubtypeFacebook];
    [self.appTimingTracker startEventWithType:VAppTimingEventTypeLogin subtype:VAppTimingEventSubtypeFacebook];
    
    FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
    if ( currentToken == nil ||
        ![[NSSet setWithArray:FacebookHelper.readPermissions] isSubsetOfSet:[currentToken permissions]] ||
        [currentToken.expirationDate timeIntervalSinceNow] <= 0)
    {
        self.actionsDisabled = YES;
        self.facebookLoginProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:FacebookHelper.readPermissions
                            fromViewController:self
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             self.actionsDisabled = NO;
             [self.facebookLoginProgressHUD hide:YES];
             self.facebookLoginProgressHUD = nil;
             
             if ( [FBSDKAccessToken currentAccessToken] != nil )
             {
                 [self loginWithStoredFacebookToken];
             }
             else
             {
                 if ( result.isCancelled )
                 {
                     [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserPermissionDidChange
                                                        parameters:@{ VTrackingKeyPermissionState : VTrackingValueFacebookDidAllow,
                                                                      VTrackingKeyPermissionName : VTrackingValueDenied }];
                     NSError *cancelledError = [NSError errorWithDomain:VFacebookErrorDomain code:VSocialLoginErrorCancelled userInfo:nil];
                     [self handleFacebookLoginError:cancelledError];
                 }
                 else
                 {
                     [self handleFacebookLoginError:error];
                 }
                 
                 NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:@(VAppErrorTrackingTypeFacebook) forKey:VTrackingKeyErrorType];
                 if ( error != nil )
                 {
                     [parameters setObject:@(error.code) forKey:VTrackingKeyErrorDetails];
                 }
                 [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookDidFail parameters:parameters];
             }
         }];
    }
    else
    {
        [self loginWithStoredFacebookToken];
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookSelected];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)loginWithStoredFacebookToken
{
    __weak typeof(self) weakSelf = self;
    [self showLoadingScreenWithCompletion:^
     {
         [weakSelf.loginFlowHelper queueFacebookLoginOperationWithCompletion:^(NSError *_Nullable error)
          {
              if ( VCurrentUser.exists && error == nil )
              {
                  weakSelf.actionsDisabled = NO;
                  weakSelf.isRegisteredAsNewUser = VCurrentUser.isNewUser.boolValue;
                  [weakSelf continueRegistrationFlowAfterSocialRegistration];
              }
              else
              {
                  [weakSelf handleFacebookLoginError:error];
              }
          }];
     }];
}

- (void)handleFacebookLoginError:(NSError *)error
{
    [[[FBSDKLoginManager alloc] init] logOut];
    
    switch ( error.code )
    {
        case VSocialLoginErrorCancelled:
            break;
            
        default:
            [self showAlertErrorWithTitle:NSLocalizedString(@"LoginFail", @"")
                                  message:NSLocalizedString(@"FacebookLoginFailed", @"")];
            break;
    }
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(void(^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    if (self.actionsDisabled)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self showLoadingScreenWithCompletion:^{
        self.currentOperation = [weakSelf.loginFlowHelper queueLoginOperationWithEmail:email
                                                                              password:password
                                                                            completion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled) {
            if ( error == nil )
            {
                completion(YES, nil);
                [weakSelf onAuthenticationFinishedWithSuccess:YES];
            }
            else
            {
                completion(NO, error);
            }
        }];
    }];
}

- (void)registerWithEmail:(NSString *)email
                 password:(NSString *)password
               completion:(void (^)(BOOL success, BOOL alreadyRegistered, NSError *error))completion
{
    NSParameterAssert(completion != nil);
    if (self.actionsDisabled)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self showLoadingScreenWithCompletion:^{
        self.currentOperation = [weakSelf.loginFlowHelper queueAccountCreateOperationWithEmail:email
                                                                                      password:password
                                                                                    completion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled) {
            weakSelf.isRegisteredAsNewUser = VCurrentUser.isNewUser.boolValue;
            if ( error == nil )
            {
                BOOL completeProfile = VCurrentUser.completedProfile.boolValue;
                completion(YES, completeProfile, nil);
                if (completeProfile)
                {
                    [weakSelf onAuthenticationFinishedWithSuccess:YES];
                }
                else
                {
                    [weakSelf continueRegistrationFlow];
                }
            }
            else
            {
                completion(NO, NO, error);
            }
        }];
    }];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignUpSubmit];
}

- (void)setUsername:(NSString *)username completion:(void (^)(BOOL, NSError *))completion
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.loginFlowHelper setUsername:username
                           completion:^(BOOL success, NSError *error)
     {
         completion(success, error);
         
         if (success)
         {
             [welf continueRegistrationFlow];
         }
     }];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidStartCreateProfile];
}

- (void)forgotPasswordWithInitialEmail:(NSString *)initialEmail
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.loginFlowHelper forgotPasswordWithStartingEmail:initialEmail
                                               completion:^(BOOL success, NSError *error)
     {
         if (success)
         {
             if (![self.topViewController isKindOfClass:[VModernResetTokenViewController class]])
             {
                 UIViewController *resetTokenScreen = [self.dependencyManager viewControllerForKey:@"resetTokenScreen"];
                 [self setDelegateForScreensInArray:@[resetTokenScreen]];
                 [self pushViewController:resetTokenScreen
                                 animated:YES];
             }
         }
     }];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectResetPassword];
}

- (void)setResetToken:(NSString *)resetToken
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.loginFlowHelper setResetToken:resetToken
                             completion:^(BOOL success, NSError *error)
     {
         if (success)
         {
             // show change password screen.
             UIViewController *changePasswordScreen = [welf.dependencyManager viewControllerForKey:@"changePasswordScreen"];
             [welf setDelegateForScreensInArray:@[changePasswordScreen]];
             [welf pushViewController:changePasswordScreen
                             animated:YES];
         }
     }];
}

- (void)updateWithNewPassword:(NSString *)newPassword
                   completion:(void (^)(BOOL))completion
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self.loginFlowHelper updatePassword:newPassword
                              completion:^(BOOL success, NSError *error)
     {
         if (success)
         {
             [self onAuthenticationFinishedWithSuccess:YES];
         }
         else
         {
             completion(success);
         }
     }];
}



- (void)showPrivacyPolicy
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self showFixedWebContent:FixedWebContentTypePrivacyPolicy];
}

- (void)showTermsOfService
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self showFixedWebContent:FixedWebContentTypeTermsOfService];
}

- (void)setProfilePictureFilePath:(NSURL *)profilePictureFilePath
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    if (profilePictureFilePath == nil)
    {
        [self onAuthenticationFinishedWithSuccess:YES];
    }
    else
    {
        [self.loginFlowHelper updateProfilePictureWithPictureAtFilePath:profilePictureFilePath
                                                             completion:nil];
    }
}

- (void)continueRegistrationFlow
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    UIViewController<VLoginFlowScreen> *nextRegisterViewController = [self nextScreenAfter:self.currentScreen inArray:self.registrationScreens];
    if (nextRegisterViewController == self.currentScreen)
    {
        [self onAuthenticationFinishedWithSuccess:YES];
    }
    else
    {
        self.currentScreen = nextRegisterViewController;
        [self pushViewController:nextRegisterViewController
                        animated:YES];
    }
}

- (void)continueRegistrationFlowAfterSocialRegistration
{
    UIViewController<VLoginFlowScreen> *nextRegisterViewController = [self nextScreenInSocialRegistrationAfter:self.currentScreen inArray:self.registrationScreens];
    if ( nextRegisterViewController != nil && self.isRegisteredAsNewUser )
    {
        self.currentScreen = nextRegisterViewController;
        [self pushViewController:nextRegisterViewController
                        animated:YES];
    }
    else
    {
        [self onAuthenticationFinishedWithSuccess:YES];
    }
}

- (void)onAuthenticationFinishedWithSuccess:(BOOL)success
{
    if ( success )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationDone];
    }
    
    [self.view endEditing:YES];
    [self registrationDidFinishedWithSuccess:success];
}

- (UIViewController<VLoginFlowScreen> *)nextScreenInSocialRegistrationAfter:(UIViewController *)currentViewController inArray:(NSArray *)array
{
    for ( UIViewController<VLoginFlowScreen> *viewController in array )
    {
        id<VLoginFlowScreen> screen = (id<VLoginFlowScreen>)viewController;
        if ( [screen respondsToSelector:@selector(displaysAfterSocialRegistration)] && [screen displaysAfterSocialRegistration] )
        {
            return viewController;
        }
    }
    return nil;
}

- (UIViewController<VLoginFlowScreen> *)nextScreenAfter:(UIViewController *)viewController
                                                inArray:(NSArray *)array
{
    if (![array containsObject:viewController])
    {
        return [array firstObject];
    }
    
    NSUInteger currentIndex = [array indexOfObject:viewController];
    if ((currentIndex+1) < array.count)
    {
        return [array objectAtIndex:currentIndex+1];
    }
    return [array objectAtIndex:currentIndex];
}

- (void)configureFlowNavigationItemWithScreen:(UIViewController <VLoginFlowScreen> *)loginFlowScreen
{
    const BOOL isFinal = [self isFinalRegistrationScreen:loginFlowScreen];
    UIBarButtonItemStyle style = isFinal ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    NSString *title = isFinal ? NSLocalizedString(@"Done", @"") : NSLocalizedString(@"Next", @"");
    loginFlowScreen.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                                         style:style
                                                                                        target:loginFlowScreen
                                                                                        action:@selector(onContinue:)];
}

- (void)onAuthenticationFinished
{
    [self onAuthenticationFinishedWithSuccess:YES];
}

- (void)returnToLandingScreen
{
    [self popToViewController:[self.loginScreens firstObject]
                     animated:YES];
}

- (void)loginErrorAlertAcknowledged
{
    [self dismissLoadingScreen];
}

#pragma mark - Loading Screen Delegate

- (void)loadingScreenCancelled
{
    [self.currentOperation cancel];
    [self dismissLoadingScreen];
}

- (void)loadingScreenDidAppear
{
    if (self.onLoadingAppeared != nil)
    {
        self.onLoadingAppeared();
        self.onLoadingAppeared = nil;
    }
}

#pragma mark - Loading screen

- (void)showLoadingScreen
{
    self.popGestureRecognizer.enabled = NO;
    [self pushViewController:self.loadingScreen animated:YES];
}

- (void)showLoadingScreenWithCompletion:(void(^)())completion
{
    self.onLoadingAppeared = completion;
    [self showLoadingScreen];
}

- (void)dismissLoadingScreen
{
    if (self.topViewController == self.loadingScreen)
    {
        [self popViewControllerAnimated:YES];
        self.popGestureRecognizer.enabled = YES;
        self.loadingScreen.canCancel = YES;
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - NSNotification handlers

- (void)applicationWillResignActive:(NSNotification *)notification
{
    // For Facebook only, when the app loses focus, remove the HUD and re-enable all the buttons.
    // This handles the case where the user taps "Cancel" on the "This app wants to open Facebook" prompt.
    if ( self.facebookLoginProgressHUD != nil )
    {
        [self.facebookLoginProgressHUD hide:YES];
        self.facebookLoginProgressHUD = nil;
        self.actionsDisabled = NO;
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    self.animator.popping = (operation == UINavigationControllerOperationPop);
    return self.animator;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    VModernFlowControllerAnimationController *modernAnimationController = (VModernFlowControllerAnimationController *)animationController;
    if (!modernAnimationController.popping)
    {
        return nil;
    }
    if (self.popGestureRecognizer.state == UIGestureRecognizerStatePossible ||
        self.popGestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
        return nil;
    }
    return self.percentDrivenInteraction;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == [self.viewControllers firstObject] && !self.hasShownInitial)
    {
        self.hasShownInitial = YES;
        return;
    }
    self.actionsDisabled = YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.actionsDisabled = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer.numberOfTouches > 0)
    {
        return NO;
    }
    return YES;
}

@end
