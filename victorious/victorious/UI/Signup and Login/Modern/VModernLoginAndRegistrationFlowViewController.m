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
#import "VDependencyManager+VStatusBarStyle.h"
#import "VDependencyManager+VKeyboardStyle.h"

// Views + Helpers
#import "VBackgroundContainer.h"
#import "VLoginFlowAPIHelper.h"
#import "VModernResetTokenViewController.h"
#import "VModernFlowControllerAnimationController.h"
#import "VTOSViewController.h"
#import "VPrivacyPoliciesViewController.h"
#import "VEnterProfilePictureCameraViewController.h"
#import "VLoginFlowControllerDelegate.h"
#import "VPermissionsTrackingHelper.h"

#import "VForcedWorkspaceContainerViewController.h"

static NSString * const kRegistrationScreens = @"registrationScreens";
static NSString * const kLoginScreens = @"loginScreens";
static NSString * const kLandingScreen = @"landingScreen";
static NSString * const kStatusBarStyleKey = @"statusBarStyle";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";
static NSString * const kForceRegistrationKey = @"forceRegistration";

@interface VModernLoginAndRegistrationFlowViewController () <VLoginFlowControllerDelegate, VBackgroundContainer, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) VModernFlowControllerAnimationController *animator;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteraction;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *popGestureRecognizer;

@property (nonatomic, assign) VAuthorizationContext authorizationContext;
@property (nonatomic, strong) VLoginFlowCompletionBlock completionBlock;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) UIViewController<VLoginFlowScreen> *landingScreen;
@property (nonatomic, strong) NSArray *registrationScreens;
@property (nonatomic, strong) NSArray *loginScreens;
@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

// Use this as a semaphore around asynchronous user interaction (navigation pushes, social logins, etc.)
@property (nonatomic, assign) BOOL actionsDisabled;
@property (nonatomic, assign) BOOL hasShownInitial;
@property (nonatomic, assign) BOOL isRegisteredAsNewUser;
@property (nonatomic, strong) VLoginFlowAPIHelper *loginFlowHelper;

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
        [self setDelegateForScreensInArray:@[_landingScreen]];
        [self setViewControllers:@[_landingScreen]];
        
        NSNumber *shouldForce = [dependencyManager numberForKey:kForceRegistrationKey];
        if (!shouldForce.boolValue)
        {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelLoginAndRegistration)];
            _landingScreen.navigationItem.leftBarButtonItem = cancelButton;
        }
        
        // Login + Registration
        _registrationScreens = [dependencyManager arrayOfValuesConformingToProtocol:@protocol(VLoginFlowScreen)
                                                                             forKey:kRegistrationScreens];
        [self setDelegateForScreensInArray:_registrationScreens];
        [self setBoundsForScreensInArray:_registrationScreens];
        
        
        _loginScreens = [dependencyManager arrayOfValuesConformingToProtocol:@protocol(VLoginFlowScreen)
                                                                      forKey:kLoginScreens];
        [self setDelegateForScreensInArray:_loginScreens];
        [self setBoundsForScreensInArray:_loginScreens];
        
        _loginFlowHelper = [[VLoginFlowAPIHelper alloc] initWithViewControllerToPresentOn:self
                                                                        dependencyManager:dependencyManager];
        
        _animator = [[VModernFlowControllerAnimationController alloc] init];
        _percentDrivenInteraction = [[UIPercentDrivenInteractiveTransition alloc] init];
        _permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
    }
    return self;
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

- (void)setBoundsForScreensInArray:(NSArray *)array
{
    for ( UIViewController *screen in array )
    {
        screen.view.frame = self.view.bounds;
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
    
    [self.loginFlowHelper selectedTwitterAuthorizationWithCompletion:^(BOOL success, BOOL isNewUser)
    {
        self.actionsDisabled = NO;
        if ( success )
        {
            self.isRegisteredAsNewUser = isNewUser;
            [self continueRegistrationFlowAfterSocialRegistration];
        }
    }];
    
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
    
    [self.loginFlowHelper selectedFacebookAuthorizationWithCompletion:^(BOOL success, BOOL isNewUser)
    {
        self.actionsDisabled = NO;
        if ( success )
        {
            self.isRegisteredAsNewUser = isNewUser;
            [self continueRegistrationFlowAfterSocialRegistration];
        }
        else
        {
            NSString *message = NSLocalizedString(@"FacebookLoginFailed", @"");
            [self showErrorWithMessage:message];
        }
    }];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookSelected];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
}

- (void)showErrorWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
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
    
    [self.loginFlowHelper loginWithEmail:email
                                password:password
                              completion:^(BOOL success, NSError *error)
     {
         completion(success, error);
         if (success)
         {
             [self onAuthenticationFinishedWithSuccess:YES];
         }
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
    
    [self.loginFlowHelper registerWithEmail:email
                                   password:password
                                 completion:^(BOOL success, BOOL alreadyRegistered, NSError *error)
     {
         completion(success, alreadyRegistered, error);
         if (success)
         {
             if (alreadyRegistered)
             {
                 [self onAuthenticationFinishedWithSuccess:YES];
             }
             else
             {
                 [self continueRegistrationFlow];
             }
         }
     }];
    
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
                                                             completion:nil];;
    }
}

- (void)continueRegistrationFlow
{
    if (self.actionsDisabled)
    {
        return;
    }
    
    UIViewController *nextRegisterViewController = [self nextScreenAfter:self.topViewController inArray:self.registrationScreens];
    if (nextRegisterViewController == self.topViewController)
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
    UIViewController *nextRegisterViewController = [self nextScreenInSocialRegistrationAfter:self.topViewController inArray:self.registrationScreens];
    if ( nextRegisterViewController != nil && self.isRegisteredAsNewUser )
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

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
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
