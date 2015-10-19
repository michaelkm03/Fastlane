//
//  VModernLoginAndRegistrationFlowViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLoginAndRegistrationFlowViewController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VDependencyManager+VStatusBarStyle.h"
#import "VDependencyManager+VKeyboardStyle.h"

// Views + Helpers
#import "UIAlertController+VSimpleAlert.h"
#import "VBackgroundContainer.h"
#import "VLoginFlowAPIHelper.h"
#import "VModernResetTokenViewController.h"
#import "VModernFlowControllerAnimationController.h"
#import "VTOSViewController.h"
#import "VPrivacyPoliciesViewController.h"
#import "VEnterProfilePictureCameraViewController.h"
#import "VLoginFlowControllerDelegate.h"
#import "VPermissionsTrackingHelper.h"
#import "VUserManager.h"
#import "victorious-Swift.h"

#import "VForcedWorkspaceContainerViewController.h"

@import FBSDKCoreKit;
@import FBSDKLoginKit;
@import MBProgressHUD;

static NSString * const kRegistrationScreens = @"registrationScreens";
static NSString * const kLoginScreens = @"loginScreens";
static NSString * const kLandingScreen = @"landingScreen";
static NSString * const kLoadingScreen = @"loadingScreen";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernLoginAndRegistrationFlowViewController () <VLoginFlowControllerDelegate, VBackgroundContainer, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) VModernFlowControllerAnimationController *animator;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteraction;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *popGestureRecognizer;

@property (nonatomic, assign) VAuthorizationContext authorizationContext;
@property (nonatomic, strong) VLoginFlowCompletionBlock completionBlock;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIViewController<VLoginFlowScreen> *landingScreen;
@property (nonatomic, strong) ModernLoadingViewController *loadingScreen;
@property (nonatomic, strong) NSArray *registrationScreens;
@property (nonatomic, strong) NSArray *loginScreens;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

// Use this as a semaphore around asynchronous user interaction (navigation pushes, social logins, etc.)
@property (nonatomic, assign) BOOL actionsDisabled;
@property (nonatomic, assign) BOOL hasShownInitial;
@property (nonatomic, assign) BOOL isRegisteredAsNewUser;
@property (nonatomic, assign) BOOL canceledLoading; //< When the user presses cancel on the loading screen
@property (nonatomic, strong) VLoginFlowAPIHelper *loginFlowHelper;
@property (nonatomic, strong) MBProgressHUD *facebookLoginProgressHUD;

@end

@implementation VModernLoginAndRegistrationFlowViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        // Landing
        _landingScreen = [dependencyManager templateValueOfType:[UIViewController class]
                                                         forKey:kLandingScreen];
        _loadingScreen = [dependencyManager templateValueOfType:[UIViewController class]
                                                         forKey:kLoadingScreen];
        [self setDelegateForScreensInArray:@[_landingScreen, _loadingScreen]];
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

- (void)cancelLoginAndRegistration
{
    if (self.actionsDisabled)
    {
        return;
    }

    if (self.presentingViewController != nil)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:^
         {
             if (self.completionBlock != nil)
             {
                 self.completionBlock(NO);
             }
         }];
    }
    else
    {
        if (self.completionBlock != nil)
        {
            self.completionBlock(NO);
        }
    }
}

- (void)selectedLogin
{
    if (self.actionsDisabled)
    {
        return;
    }
        
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLoginWithEmail];
    
    [self pushViewController:[self.loginScreens firstObject]
                    animated:YES];
}

- (void)selectedRegister
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self pushViewController:[self nextScreenAfter:self.topViewController inArray:self.registrationScreens]
                    animated:YES];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignupWithEmail];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)selectedTwitterAuthorization
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    self.actionsDisabled = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.loadingScreen setOnAppearance:^{
        
        __strong VModernLoginAndRegistrationFlowViewController *strongSelf = weakSelf;
        
        [strongSelf.loginFlowHelper selectedTwitterAuthorizationWithCompletion:^(BOOL success, BOOL isNewUser)
         {
             strongSelf.actionsDisabled = NO;

             // User canceled log in, do nothing
             if (strongSelf.canceledLoading)
             {
                 VUserManager *userManager = [[VUserManager alloc] init];
                 [userManager userDidLogout];
                 return;
             }
             
             if ( success )
             {
                 strongSelf.isRegisteredAsNewUser = isNewUser;
                 [strongSelf continueRegistrationFlowAfterSocialRegistration];
             }
             else
             {
                 [weakSelf dismissLoadingScreen];
             }
         }];
       
    }];
    
    [self showLoadingScreen];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterSelected];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)selectedFacebookAuthorization
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    self.actionsDisabled = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.loadingScreen setOnAppearance:^{
        
        __strong VModernLoginAndRegistrationFlowViewController *strongSelf = weakSelf;
        
        if ( [FBSDKAccessToken currentAccessToken] == nil ||
            ![[NSSet setWithArray:VFacebookHelper.readPermissions] isSubsetOfSet:[[FBSDKAccessToken currentAccessToken] permissions]] )
        {
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            loginManager.forceNative = [strongSelf.dependencyManager shouldForceNativeFacebookLogin];
            [loginManager logInWithReadPermissions:VFacebookHelper.readPermissions
                                fromViewController:strongSelf
                                           handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
             {
                 // User canceled log in, do nothing
                 if (strongSelf.canceledLoading)
                 {
                     strongSelf.actionsDisabled = NO;
                     return;
                 }
                 
                 if ( [FBSDKAccessToken currentAccessToken] != nil )
                 {
                     [strongSelf loginWithStoredFacebookToken];
                 }
                 else
                 {
                     if ( result.isCancelled )
                     {
                         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserPermissionDidChange
                                                            parameters:@{ VTrackingKeyPermissionState : VTrackingValueFacebookDidAllow,
                                                                          VTrackingKeyPermissionName : VTrackingValueDenied }];
                     }
                     [strongSelf handleFacebookLoginFailure];
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
            [strongSelf loginWithStoredFacebookToken];
        }
    }];
    
    [self showLoadingScreen];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookSelected];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)loginWithStoredFacebookToken
{
    self.actionsDisabled = YES;
    
    VUserManager *userManager = [[VUserManager alloc] init];
    [userManager loginViaFacebookWithStoredTokenOnCompletion:^(VUser *user, BOOL isNewUser)
    {
        self.actionsDisabled = NO;
        
        if (self.canceledLoading)
        {
            return;
        }

        self.isRegisteredAsNewUser = isNewUser;
        [self continueRegistrationFlowAfterSocialRegistration];
    }
                                                     onError:^(NSError *error, BOOL thirdPartyAPIFailure)
    {
        self.actionsDisabled = NO;
        
        if (self.canceledLoading)
        {
            return;
        }
        
        [self handleFacebookLoginFailure];
    }];
}

- (void)handleFacebookLoginFailure
{
    [self dismissLoadingScreen];
    UIAlertController *alertController = [UIAlertController simpleAlertControllerWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                                                   message:NSLocalizedString(@"FacebookLoginFailed", @"")
                                                                      andCancelButtonTitle:NSLocalizedString(@"OK", @"")];
    [self presentViewController:alertController animated:YES completion:nil];
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
    [self.loadingScreen setOnAppearance:^
    {
        __strong VModernLoginAndRegistrationFlowViewController *strongSelf = weakSelf;
        
        [strongSelf.loginFlowHelper loginWithEmail:email
                                          password:password
                                        completion:^(BOOL success, NSError *error)
         {
             completion(success, error);
             if (success)
             {
                 [strongSelf onAuthenticationFinishedWithSuccess:YES];
             }
             else
             {
                 [strongSelf dismissLoadingScreen];
             }
         }];
    }];
    
    [self showLoadingScreen];
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
    [self.loadingScreen setOnAppearance:^
    {
        __strong VModernLoginAndRegistrationFlowViewController *strongSelf = weakSelf;

        [strongSelf.loginFlowHelper registerWithEmail:email
                                             password:password
                                           completion:^(BOOL success, BOOL alreadyRegistered, NSError *error)
         {
             completion(success, alreadyRegistered, error);
             if (success)
             {
                 if (alreadyRegistered)
                 {
                     [strongSelf onAuthenticationFinishedWithSuccess:YES];
                 }
                 else
                 {
                     [strongSelf continueRegistrationFlow];
                 }
             }
             else
             {
                 [strongSelf dismissLoadingScreen];
             }
         }];
    }];
    
    [self showLoadingScreen];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignUpSubmit];
}

- (void)setUsername:(NSString *)username
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.loginFlowHelper setUsername:username
                           completion:^(BOOL success, NSError *error)
    {
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
    
    [self presentViewController:[VPrivacyPoliciesViewController presentableTermsOfServiceViewControllerWithDependencyManager:self.dependencyManager]
                       animated:YES
                     completion:nil];
}

- (void)showTermsOfService
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    [self presentViewController:[VTOSViewController presentableTermsOfServiceViewController]
                       animated:YES
                     completion:nil];
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
    
    // Loading screen is not technically part of the flow, so we must use the 2nd to last view controller
    UIViewController *currentViewController = self.topViewController;
    if (currentViewController == self.loadingScreen)
    {
        currentViewController = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    
    UIViewController *nextRegisterViewController = [self nextScreenAfter:currentViewController inArray:self.registrationScreens];
    if (nextRegisterViewController == currentViewController)
    {
        [self onAuthenticationFinishedWithSuccess:YES];
    }
    else
    {
        [self pushViewController:nextRegisterViewController
                        animated:YES];
    }
}

- (void)continueRegistrationFlowAfterSocialRegistration
{
    // Loading screen is not technically part of the flow, so we must use the 2nd to last view controller
    UIViewController *currentViewController = self.topViewController;
    if (currentViewController == self.loadingScreen)
    {
        currentViewController = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    
    UIViewController *nextRegisterViewController = [self nextScreenInSocialRegistrationAfter:currentViewController inArray:self.registrationScreens];
    if ( nextRegisterViewController != nil && !self.isRegisteredAsNewUser )
    {
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
    if (self.presentingViewController != nil)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:^
         {
             if (self.completionBlock != nil)
             {
                 self.completionBlock(success);
             }
         }];
    }
    else
    {
        if (self.completionBlock != nil)
        {
            self.completionBlock(success);
        }
    }
}

- (UIViewController *)nextScreenInSocialRegistrationAfter:(UIViewController *)currentViewController inArray:(NSArray *)array
{
    for ( UIViewController *viewController in array )
    {
        id<VLoginFlowScreen> screen = (id<VLoginFlowScreen>)viewController;
        if ( [screen respondsToSelector:@selector(displaysAfterSocialRegistration)] && [screen displaysAfterSocialRegistration] )
        {
            return viewController;
        }
    }
    return nil;
}

- (UIViewController *)nextScreenAfter:(UIViewController *)viewController
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

#pragma mark - Loading screen

- (void)loadingScreenCanceled
{
    self.canceledLoading = YES;
    [self dismissLoadingScreen];
}

- (void)showLoadingScreen
{
    self.canceledLoading = NO;
    [self pushViewController:self.loadingScreen animated:YES];
}

- (void)dismissLoadingScreen
{
    if ([self.topViewController isEqual:self.loadingScreen])
    {
        [self popViewControllerAnimated:YES];
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
