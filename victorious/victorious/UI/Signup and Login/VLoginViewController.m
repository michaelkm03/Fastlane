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
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VProfileCreateViewController.h"
#import "VUserManager.h"
#import "VLoginTransitionAnimator.h"
#import "VSignupTransitionAnimator.h"
#import "UIImage+ImageCreation.h"
#import <MBProgressHUD/MBProgressHUD.h>

#import "VSelectorViewController.h"
#import "VLoginWithEmailViewController.h"
#import "VSignupWithEmailViewController.h"
#import "VObjectManager.h"
#import "VAutomation.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()  <UINavigationControllerDelegate, VSelectorViewControllerDelegate>

@property (nonatomic, strong)           VUser          *profile;

@property (nonatomic, weak) IBOutlet    UIButton       *facebookButton;
@property (nonatomic, weak) IBOutlet    UIButton       *twitterButton;

@property (nonatomic, weak) IBOutlet    UIImageView    *backgroundImageView;
@property (nonatomic, weak) IBOutlet    UILabel        *fauxEmailLoginButton;
@property (nonatomic, weak) IBOutlet    UILabel        *fauxPasswordLoginButton;

@property (nonatomic, weak) IBOutlet    UILabel        *facebookButtonLabel;
@property (nonatomic, weak) IBOutlet    UILabel        *twitterButtonLabel;
@property (nonatomic, weak) IBOutlet    UIButton       *signupWithEmailButton;

@property (nonatomic, assign)           VLoginType      loginType;

@end

@implementation VLoginViewController

+ (VLoginViewController *)loginViewController
{
    UIStoryboard   *storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage    *backgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice]
                                   applyBlurWithRadius:0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    
    self.backgroundImageView.image = backgroundImage;
    [self addGradientToImageView:self.backgroundImageView];

    self.fauxEmailLoginButton.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.fauxEmailLoginButton.textColor = [UIColor whiteColor];
    self.fauxPasswordLoginButton.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.fauxPasswordLoginButton.textColor = [UIColor whiteColor];
    
    self.facebookButtonLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.facebookButtonLabel.textColor = [UIColor whiteColor];
    self.twitterButtonLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.twitterButtonLabel.textColor = [UIColor whiteColor];
    self.signupWithEmailButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    
    self.fauxEmailLoginButton.accessibilityIdentifier = VAutomationIdentifierLoginSelectEmail;
    self.fauxPasswordLoginButton.accessibilityIdentifier = VAutomationIdentifierLoginSelectPassword;
    self.signupWithEmailButton.accessibilityIdentifier = VAutomationIdentifierLoginSignUp;
    
    [self.transitionPlaceholder addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailClicked:)]];
    self.transitionPlaceholder.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAbortCreateProfile:) name:VProfileCreateViewControllerWasAbortedNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIImage    *cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonClicked:)];
    
    self.navigationController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Login"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Login"];
    
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
    return YES;
}

#pragma mark - Support

- (void)addGradientToImageView:(UIView *)view
{
    CAGradientLayer    *gradient    =   [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (void)twitterAccessDidFail:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TwitterDeniedTitle", @"")
                                                    message:NSLocalizedString(@"TwitterDenied", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didFailWithError:(NSError *)error
{
    if (error.code != kVUserBannedError)
    {
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                               message:error.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Actions

- (IBAction)facebookClicked:(id)sender
{
    [self disableButtons];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookSelected];
    [[VUserManager sharedInstance] loginViaFacebookOnCompletion:^(VUser *user, BOOL created)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookDidSucceed];
                           self.profile = user;
                           if ( [self.profile.status isEqualToString:kUserStatusIncomplete] )
                           {
                               [self performSegueWithIdentifier:@"toProfileWithFacebook" sender:self];
                           }
                           else
                           {
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                       });
    }
                                                         onError:^(NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithFacebookDidFail];
            [self didFailWithError:error];
            [self enableButtons];
        });
    }];
}

- (IBAction)twitterClicked:(id)sender
{
    [self disableButtons];
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterSelected];
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailNoAccounts];
                [self enableButtons];
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
                    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailDenied];
                    [self enableButtons];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoTwitterTitle", @"")
                                                                    message:NSLocalizedString(@"NoTwitterMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
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

- (void)disableButtons
{
    self.facebookButton.enabled = NO;
    self.twitterButton.enabled = NO;
    self.signupWithEmailButton.userInteractionEnabled = NO;
    self.transitionPlaceholder.userInteractionEnabled = NO;
}

- (void)enableButtons
{
    self.facebookButton.enabled = YES;
    self.twitterButton.enabled = YES;
    self.signupWithEmailButton.userInteractionEnabled = YES;
    self.transitionPlaceholder.userInteractionEnabled = YES;
}

- (IBAction)emailClicked:(id)sender
{
    [self performSegueWithIdentifier:@"toEmailLogin" sender:self];
}

- (IBAction)signup:(id)sender
{
    [self performSegueWithIdentifier:@"toSignup" sender:self];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelLogin];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        VProfileCreateViewController   *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeFaceBook;
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
        
        profileViewController.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        VProfileCreateViewController   *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeTwitter;
        profileViewController.profile = self.profile;
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeEmail;
        profileViewController.profile = self.profile;
    }
}

- (void)userDidAbortCreateProfile:(NSNotification *)note
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VSelectorViewControllerDelegate

- (void)vSelectorViewController:(VSelectorViewController *)selectorViewController
                  didSelectItem:(id)selectedItem
{
    [self attemptLoginWithTwitterAccount:selectedItem];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)vSelectorViewControllerDidCancel:(VSelectorViewController *)selectorViewController
{
    [self enableButtons];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)attemptLoginWithTwitterAccount:(ACAccount *)twitterAccount
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view
                         animated:YES];
    [[VUserManager sharedInstance] loginViaTwitterWithTwitterID:twitterAccount.identifier
                                                   OnCompletion:^(VUser *user, BOOL created)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view
                              animated:YES];
         
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidSucceed];
         
         self.profile = user;
         if ( [self.profile.status isEqualToString:kUserStatusIncomplete] )
         {
             [self performSegueWithIdentifier:@"toProfileWithTwitter" sender:self];
         }
         else
         {
             [self dismissViewControllerAnimated:YES completion:NULL];
         }
         
     } onError:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view
                              animated:YES];
         
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithTwitterDidFailUnknown];
         
         [self enableButtons];
         [self didFailWithError:error];
     }];
}

@end
