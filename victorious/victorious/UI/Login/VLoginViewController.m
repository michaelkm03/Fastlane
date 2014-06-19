//
//  VLoginViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VLoginViewController.h"
#import "VConstants.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VProfileCreateViewController.h"
#import "VUserManager.h"
#import "VLoginTransitionAnimator.h"
#import "VSignupTransitionAnimation.h"
#import "UIImage+ImageCreation.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()  <UINavigationControllerDelegate>
@property (nonatomic, strong)           VUser*          profile;

@property (nonatomic, weak) IBOutlet    UIButton*       facebookButton;
@property (nonatomic, weak) IBOutlet    UIButton*       twitterButton;

@property (nonatomic, weak) IBOutlet    UIImageView*    backgroundImageView;
@property (nonatomic, weak) IBOutlet    UILabel*        fauxEmailLoginButton;
@property (nonatomic, weak) IBOutlet    UILabel*        fauxPasswordLoginButton;

@property (nonatomic, weak) IBOutlet    UILabel*        facebookButtonLabel;
@property (nonatomic, weak) IBOutlet    UILabel*        twitterButtonLabel;
@property (nonatomic, weak) IBOutlet    UIButton*       loginEmailButton;

@property (nonatomic, assign)           VLoginType      loginType;
@property (nonatomic, assign)           BOOL            animateToLogin;
@property (nonatomic, assign)           BOOL            animateToSignup;
@end

@implementation VLoginViewController

+ (VLoginViewController *)loginViewController
{
    UIStoryboard*   storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    return [storyboard instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage*    backgroundImage;
    if (IS_IPHONE_5)
        backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyBlurWithRadius:0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    else
        backgroundImage = [[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyBlurWithRadius:0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    
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
    self.loginEmailButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    
    [self.transitionPlaceholder addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailClicked:)]];
    self.transitionPlaceholder.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIImage*    cancelButtonImage = [[UIImage imageNamed:@"cameraButtonClose"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cancelButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(closeButtonClicked:)];
    
    self.navigationController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Login"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
    
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
    CAGradientLayer*    gradient    =   [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor];
    [view.layer insertSublayer:gradient atIndex:0];
}

- (void)facebookAccessDidFail:(NSError *)error
{
    if (error.code == ACErrorAccountNotFound)
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self presentViewController:composeViewController animated:NO completion:^{
            [composeViewController dismissViewControllerAnimated:NO completion:nil];
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FacebookDeniedTitle", @"")
                                                        message:NSLocalizedString(@"FacebookDenied", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
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

- (void)didFailWithError:(NSError*)error
{
    if(error.code == kVUserBannedError)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserBannedTitle", @"")
                                                               message:NSLocalizedString(@"UserBannedMessage", @"")
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
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
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Start Login Via Facebook" label:nil value:nil];
    [[VUserManager sharedInstance] loginViaFacebookOnCompletion:^(VUser *user, BOOL created)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Successful Login Via Facebook" label:nil value:nil];
            self.profile = user;
            if (created)
            {
                [self performSegueWithIdentifier:@"toProfileWithFacebook" sender:self];
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        });
    }
                                                         onError:^(NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Failed Login Via Facebook" label:nil value:nil];
            [self didFailWithError:error];
            [self enableButtons];
        });
    }];
}

- (IBAction)twitterClicked:(id)sender
{
    [self disableButtons];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Start Login Via Twitter" label:nil value:nil];
    
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Twitter Account Access Denied" label:nil value:nil];
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
                    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"User Has No Twitter Accounts" label:nil value:nil];
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
                [[VUserManager sharedInstance] loginViaTwitterOnCompletion:^(VUser *user, BOOL created)
                {
                    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Successful Login Via Twitter" label:nil value:nil];
                    self.profile = user;
                    if (created)
                    {
                        [self performSegueWithIdentifier:@"toProfileWithTwitter" sender:self];
                    }
                    else
                    {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                }
                                                                    onError:^(NSError *error)
                {
                    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryUserAccount action:@"Failed Login Via Twitter" label:nil value:nil];
                    [self enableButtons];
                    [self didFailWithError:error];
                }];
            }
        }
    }];
}

- (void)disableButtons
{
    self.facebookButton.enabled = NO;
    self.twitterButton.enabled = NO;
    self.loginEmailButton.userInteractionEnabled = NO;
    self.transitionPlaceholder.userInteractionEnabled = NO;
}

- (void)enableButtons
{
    self.facebookButton.enabled = YES;
    self.twitterButton.enabled = YES;
    self.loginEmailButton.userInteractionEnabled = YES;
    self.transitionPlaceholder.userInteractionEnabled = YES;
}

- (IBAction)emailClicked:(id)sender
{
    self.animateToLogin = YES;
    [self performSegueWithIdentifier:@"toEmailLogin" sender:self];
}

- (IBAction)signup:(id)sender
{
    self.animateToSignup = YES;
    [self performSegueWithIdentifier:@"toSignup" sender:self];
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryNavigation action:@"Cancel Login" label:nil value:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        VProfileCreateViewController*   profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeFaceBook;
        profileViewController.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        VProfileCreateViewController*   profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeTwitter;
        profileViewController.profile = self.profile;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (self.animateToLogin)
    {
        self.animateToLogin = NO;
        
        VLoginTransitionAnimator*   animator = [[VLoginTransitionAnimator alloc] init];
        animator.presenting = (operation == UINavigationControllerOperationPush);
        return animator;
    }
    
    if (self.animateToSignup)
    {
        self.animateToSignup = NO;
        
        VSignupTransitionAnimation* animator = [[VSignupTransitionAnimation alloc] init];
        animator.presenting = (operation == UINavigationControllerOperationPush);
        return animator;
    }
    
    return nil;
}

@end
