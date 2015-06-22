//
//  VLoginViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VConstants.h"
#import "VUser.h"
#import "UIImage+ImageEffects.h"
#import "VProfileCreateViewController.h"
#import "VUserManager.h"
#import "UIImage+ImageCreation.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "VLoginWithEmailViewController.h"
#import "VSignupWithEmailViewController.h"
#import "VObjectManager.h"
#import "VAutomation.h"

#import "VLoginButton.h"

#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"
#import "VLinkTextViewHelper.h"
#import "MBProgressHUD.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager.h"
#import "VCreatorMessageViewController.h"
#import "UIAlertView+VBlocks.h"
#import "VDependencyManager+VTracking.h"
#import "VTwitterAccountsHelper.h"
#import "UIView+AutoLayout.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()  <UINavigationControllerDelegate, CCHLinkTextViewDelegate, VRegistrationStepDelegate>

@property (nonatomic, strong) VUser *profile;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet VLoginButton *facebookButton;
@property (nonatomic, weak) IBOutlet VLoginButton *twitterButton;
@property (nonatomic, weak) IBOutlet VLoginButton *signupWithEmailButton;
@property (nonatomic, weak) IBOutlet UIView *creatorMessgeContainerView;

@property (nonatomic, weak) IBOutlet CCHLinkTextView *loginTextView;

@property (nonatomic, assign) VLoginType loginType;
@property (nonatomic, strong) VLinkTextViewHelper *linkTextHelper;
@property (nonatomic, weak) IBOutlet VAuthorizationContextHelper *authorizationContextHelper;

@property (nonatomic, strong) VCreatorMessageViewController *creatorMessageView;

@end

@implementation VLoginViewController

@synthesize authorizedAction; //< VAuthorizationProvider

+ (VLoginViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    VLoginViewController *viewController = (VLoginViewController *)[storyboard instantiateInitialViewController];
    viewController.dependencyManager = dependencyManager;
    viewController.linkTextHelper = [[VLinkTextViewHelper alloc] initWithDependencyManager:dependencyManager];
    return viewController;
}

- (void)loginDidFinishWithSuccess:(BOOL)success
{
    NSAssert( self.navigationController != nil && [self.navigationController.viewControllers.firstObject isEqual:self],
             @"VLoginViewController can only exist as the root view controller of a navigation controller." );
    
    // If we're dismissing from a subsequently pushed navigation controller, disable the custom transition
    if ( self.navigationController.viewControllers.count > 1 )
    {
        self.navigationController.transitioningDelegate = nil;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFinishRegistration];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^void
     {
         if ( self.authorizedAction != nil )
         {
             self.authorizedAction(success);
         }
     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.facebookButton setFont:[self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey]];
    [self.facebookButton setTextColor:[UIColor whiteColor]];
    self.facebookButton.accessibilityIdentifier = VAutomationIdentifierLoginFacebook;
    
    [self.signupWithEmailButton setFont:[self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey]];
    [self.signupWithEmailButton setTextColor:[UIColor whiteColor]];
    self.signupWithEmailButton.accessibilityIdentifier = VAutomationIdentifierLoginSignUp;
    
    [self.twitterButton setFont:[self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey]];
    [self.twitterButton setTextColor:[UIColor whiteColor]];
    self.twitterButton.accessibilityIdentifier = VAutomationIdentifierLoginTwitter;
    
    NSString *linkText = NSLocalizedString( @"Log in here", @"" );
    NSString *normalText = NSLocalizedString( @"Already Registered?", @"" );
    NSString *text = [NSString stringWithFormat:@"%@ %@", normalText, linkText];
    NSRange range = [text rangeOfString:linkText];
    [self.linkTextHelper setupLinkTextView:self.loginTextView withText:text range:range];
    self.loginTextView.linkDelegate = self;
    
    // Some prep for VPresentWithBlurViewController background
    self.blurredBackgroundView = [self createBackgroundView:self.view.bounds];
    [self.view addSubview:self.blurredBackgroundView];
    [self.view sendSubviewToBack:self.blurredBackgroundView];
    [self.view v_addFitToParentConstraintsToSubview:self.blurredBackgroundView];
    
    NSString *authorizationContextText = [self.authorizationContextHelper textForContext:self.authorizationContextType];
    self.creatorMessageView = [[VCreatorMessageViewController alloc] initWithDependencyManager:self.dependencyManager];
    [self.creatorMessageView setMessage:authorizationContextText];
    [self.creatorMessageView willMoveToParentViewController:self];
    [self.creatorMessgeContainerView addSubview:self.creatorMessageView.view];
    [self.creatorMessageView didMoveToParentViewController:self];
    [self.creatorMessgeContainerView v_addFitToParentConstraintsToSubview:self.creatorMessageView.view];
    
    // Some prep for VPresentWithBlurViewController animation (this is the order elements animate on screen)
    NSArray *elementsArray = @[ self.creatorMessageView.view,
                                self.signupWithEmailButton,
                                self.facebookButton,
                                self.twitterButton,
                                self.loginTextView ];
    self.stackedElements = [NSOrderedSet orderedSetWithArray:elementsArray];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidStartRegistration];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.navigationController.delegate = self;
    
    if ( self.isBeingPresented || self.navigationController.isBeingPresented )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginDidShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self)
    {
        self.navigationController.delegate = nil;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    //Simply don't change the hidden state of the status bar
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectLoginWithEmail];
    
    [self performSegueWithIdentifier:@"toEmailLogin" sender:self];
}

#pragma mark - VRegistrationStepDelegate

- (void)didFinishRegistrationStepWithSuccess:(BOOL)success
{
    [self loginDidFinishWithSuccess:success];
}

#pragma mark - Helpers

- (UIView *)createBackgroundView:(CGRect)bounds
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = bounds;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bounds;
    gradientLayer.colors = @[ (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                              (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                              (id)[UIColor colorWithWhite:0.0 alpha:0.8].CGColor ];
    [blurEffectView.layer insertSublayer:gradientLayer atIndex:(unsigned)(blurEffectView.layer.sublayers.count-1)];
    return blurEffectView;
}

- (void)twitterAccessDidFail:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TwitterDeniedTitle", @"")
                                                    message:NSLocalizedString(@"TwitterDenied", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)twitterLoginFailedWithError:(NSError *)error fromTwitterAPI:(BOOL)fromTwitterAPI
{
    if ( error.code != kVUserBannedError )
    {
        NSString *message = NSLocalizedString(@"TwitterTroubleshooting", @"");
        if ( error.code == NSURLErrorNetworkConnectionLost || !fromTwitterAPI )
        {
            //We've encountered a network error, show the localized description instead of the twitter troubleshooting tips
            message = error.localizedDescription;
        }
        [self showLoginFailureAlertWithMessage:message];
    }
}

- (void)facebookLoginFailedWithError:(NSError *)error
{
    if ( error.code != kVUserBannedError )
    {
        NSString *message = error.localizedDescription;
        [self showLoginFailureAlertWithMessage:message];
    }
}

- (void)showLoginFailureAlertWithMessage:(NSString *)message
{
    UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                           message:message
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Actions

- (IBAction)facebookClicked:(id)sender
{
    [self showLoginProgress];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookSelected];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
    [[VUserManager sharedInstance] loginViaFacebookOnCompletion:^(VUser *user, BOOL created)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           self.profile = user;
                           if ( [self.profile.status isEqualToString:kUserStatusIncomplete] )
                           {
                               [self performSegueWithIdentifier:@"toProfileWithFacebook" sender:self];
                           }
                           else
                           {
                               [self loginDidFinishWithSuccess:YES];
                           }
                       });
    }
                                                         onError:^(NSError *error, BOOL thirdPartyAPIFailed)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
                           [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookDidFail parameters:params];
                           
                           [self facebookLoginFailedWithError:error];
                           [self hideLoginProgress];
                       });
    }];
}

- (IBAction)twitterClicked:(id)sender
{
    [self showLoginProgress];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterSelected];
    
    VTwitterAccountsHelper *twitterHelper = [[VTwitterAccountsHelper alloc] init];
    
    [twitterHelper selectTwitterAccountWithViewControler:self
                                           completion:^(ACAccount *twitterAccount)
     {
         [self hideLoginProgress];
         [self attemptLoginWithTwitterAccount:twitterAccount];
     }];
}

- (void)showLoginProgress
{
    self.twitterButton.enabled = NO;
    self.facebookButton.enabled = NO;
    self.signupWithEmailButton.enabled = NO;
}

- (void)hideLoginProgress
{
    self.twitterButton.enabled = YES;
    self.facebookButton.enabled = YES;
    self.signupWithEmailButton.enabled = YES;
}

- (IBAction)signup:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignupWithEmail];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectRegistrationOption];
    
    [self performSegueWithIdentifier:@"toSignup" sender:self];
}

- (IBAction)onDismiss:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelLogin];
    
    [self loginDidFinishWithSuccess:NO];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VRegistrationModel *registrationModelForUser = [VRegistrationModel registrationModelWithUser:self.profile];
    
    if ( [segue.destinationViewController isKindOfClass:[VCreatorMessageViewController class]] )
    {
        // Get reference to the embedded container view from storybaord
        self.creatorMessageView = segue.destinationViewController;
        self.creatorMessageView.dependencyManager = self.dependencyManager;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.loginType = VLoginTypeFaceBook;
        profileViewController.registrationModel = registrationModelForUser;
        profileViewController.registrationStepDelegate = self;
        profileViewController.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.loginType = VLoginTypeTwitter;
        profileViewController.profile = self.profile;
        profileViewController.registrationStepDelegate = self;
        profileViewController.registrationModel = registrationModelForUser;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.loginType = VLoginTypeEmail;
        profileViewController.registrationStepDelegate = self;
        profileViewController.profile = self.profile;
        profileViewController.registrationModel = registrationModelForUser;
    }
    else if ([segue.identifier isEqualToString:@"toEmailLogin"])
    {
        VLoginWithEmailViewController *viewController = (VLoginWithEmailViewController *)segue.destinationViewController;
        viewController.registrationStepDelegate = self;
        viewController.dependencyManager = self.dependencyManager;
    }
    else if ([segue.identifier isEqualToString:@"toSignup"])
    {
        VSignupWithEmailViewController *viewController = (VSignupWithEmailViewController *)segue.destinationViewController;
        viewController.registrationStepDelegate = self;
        viewController.dependencyManager = self.dependencyManager;
    }
}

- (void)attemptLoginWithTwitterAccount:(ACAccount *)twitterAccount
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[VUserManager sharedInstance] loginViaTwitterWithTwitterID:twitterAccount.identifier
                                                   OnCompletion:^(VUser *user, BOOL created)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
         
         self.profile = user;
         if ( [self.profile.status isEqualToString:kUserStatusIncomplete] )
         {
             [self performSegueWithIdentifier:@"toProfileWithTwitter" sender:self];
         }
         else
         {
             [self loginDidFinishWithSuccess:YES];
         }
         
     }
                                                        onError:^(NSError *error, BOOL thirdPartyAPIFailed)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
         
         NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailUnknown parameters:params];
         
         [self hideLoginProgress];
         [self twitterLoginFailedWithError:error fromTwitterAPI:thirdPartyAPIFailed];
     }];
}

@end
