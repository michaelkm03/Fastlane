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

#import "VSelectorViewController.h"
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
#import "VCreatorInfoHelper.h"
#import "UIAlertView+VBlocks.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()  <UINavigationControllerDelegate, VSelectorViewControllerDelegate, CCHLinkTextViewDelegate, VRegistrationStepDelegate>

@property (nonatomic, strong) VUser *profile;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet VLoginButton *facebookButton;
@property (nonatomic, weak) IBOutlet VLoginButton *twitterButton;
@property (nonatomic, weak) IBOutlet VLoginButton *signupWithEmailButton;

@property (nonatomic, weak) IBOutlet CCHLinkTextView *loginTextView;

@property (nonatomic, assign) VLoginType loginType;
@property (nonatomic, weak) IBOutlet VLinkTextViewHelper *linkTextHelper;
@property (nonatomic, weak) IBOutlet VAuthorizationContextHelper *authorizationContextHelper;

@property (nonatomic, weak) IBOutlet UITextView *authorizationContextTextView;
@property (nonatomic, weak) IBOutlet VCreatorInfoHelper *creatorInfoHelper;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@end

@implementation VLoginViewController

@synthesize authorizedAction; //< VAuthorizationProvider

+ (VLoginViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    VLoginViewController *viewController = (VLoginViewController *)[storyboard instantiateInitialViewController];
    viewController.dependencyManager = dependencyManager;
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
    
    // Some prep for VPresentWithBlurViewController animation (this is the order elements animate on screen)
    NSArray *elementsArray = @[ self.contentContainer,
                                self.signupWithEmailButton,
                                self.facebookButton,
                                self.twitterButton,
                                self.loginTextView ];
    self.stackedElements = [NSOrderedSet orderedSetWithArray:elementsArray];
    
    NSString *authorizationContextText = [self.authorizationContextHelper textForContext:self.authorizationContextType];
    NSDictionary *attributes = [self stringAttributesWithFont:[self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]
                                                        color:[UIColor whiteColor]
                                                   lineHeight:23.0f];
    self.authorizationContextTextView.attributedText = [[NSAttributedString alloc] initWithString:authorizationContextText attributes:attributes];
    
    [self.creatorInfoHelper populateViewsWithDependencyManager:self.dependencyManager];
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

#pragma mark - VPresentWithBlurViewController

- (void)setTransitionDelegate:(VTransitionDelegate *)transitionDelegate
{
    _transitionDelegate = transitionDelegate;
    
    UIViewController *viewController = self;
    if ( self.navigationController != nil )
    {
        viewController = self.navigationController;
    }
    
    viewController.transitioningDelegate = transitionDelegate;
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

- (NSDictionary *)stringAttributesWithFont:(UIFont *)font color:(UIColor *)color lineHeight:(CGFloat)lineHeight
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = lineHeight;
    
    return @{ NSFontAttributeName: font ?: [NSNull null],
              NSForegroundColorAttributeName: color,
              NSParagraphStyleAttributeName: paragraphStyle };
}

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
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterSelected];
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
                               [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailDenied parameters:params];
                               
                               [self hideLoginProgress];
                               [self twitterAccessDidFail:error];
                           });
        }
        else
        {
            NSArray *twitterAccounts = [account accountsWithAccountType:accountType];
            if (!twitterAccounts.count)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
                    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailNoAccounts parameters:params];
                    
                    [self hideLoginProgress];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoTwitterTitle", @"")
                                                                    message:NSLocalizedString(@"NoTwitterMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //TODO: this should use VTwitterManager's fetchTwitterInfoWithSuccessBlock:FailBlock method
                    ACAccountStore *account = [[ACAccountStore alloc] init];
                    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                    NSArray *accounts = [account accountsWithAccountType:accountType];
                    
                    if (accounts.count == 1)
                    {
                        [self attemptLoginWithTwitterAccount:[accounts firstObject]];
                        return;
                    }
                    
                    // Select from n twitter accounts
                    VSelectorViewController *selectorVC = [VSelectorViewController selectorViewControllerWithItemsToSelectFrom:accounts
                                                                                                            withConfigureBlock:^(UITableViewCell *cell, ACAccount *account) {
                                                                                                                cell.textLabel.text = account.username;
                                                                                                                cell.detailTextLabel.text = account.accountDescription;
                                                                                                            }];
                    selectorVC.delegate = self;
                    selectorVC.navigationItem.prompt = NSLocalizedString(@"SelectTwitter", @"");
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectorVC];
                    [self presentViewController:navController
                                       animated:YES
                                     completion:nil];
                });
            }
        }
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
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.loginType = VLoginTypeFaceBook;
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
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
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.loginType = VLoginTypeEmail;
        profileViewController.registrationStepDelegate = self;
        profileViewController.profile = self.profile;
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

#pragma mark - VSelectorViewControllerDelegate

- (void)vSelectorViewController:(VSelectorViewController *)selectorViewController didSelectItem:(id)selectedItem
{
    [self attemptLoginWithTwitterAccount:selectedItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vSelectorViewControllerDidCancel:(VSelectorViewController *)selectorViewController
{
    [self hideLoginProgress];
    [self dismissViewControllerAnimated:YES completion:nil];
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
