//
//  VLoginViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginViewController.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "VProfileWithSocialViewController.h"
#import "VLoginWithEmailViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"
#import "VLoginTransitionAnimator.h"

@import Accounts;
@import Social;

@interface VLoginViewController ()  <UINavigationControllerDelegate>
@property (nonatomic, weak) IBOutlet    UIView*             buttonContainer;
@property (nonatomic, weak) IBOutlet    UIButton*           facebookButton;
@property (nonatomic, weak) IBOutlet    UIButton*           twitterButton;
@property (nonatomic, weak) IBOutlet    UIButton*           emailButton;
@property (nonatomic, weak) IBOutlet    UIButton*           signinEmailButton;

@property (nonatomic, weak) IBOutlet    UILabel*           loginLabel;

@property (nonatomic, strong)           UIDynamicAnimator*  animator;
@property (nonatomic, assign)           VLoginType          loginType;
@property (nonatomic, strong)           VUser*              profile;

@end

@implementation VLoginViewController

+ (VLoginViewController *)loginViewController
{
    UIStoryboard*   storyboard  =   [UIStoryboard storyboardWithName:@"login" bundle:nil];
    
    return [storyboard instantiateInitialViewController];
}

- (void)viewDidLoad
{
    if (IS_IPHONE_5)
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5].CGImage;
    else
        self.view.layer.contents = (id)[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage].CGImage;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIColor* accentColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    UIFont* font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.loginLabel.textColor = accentColor;
    self.loginLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton1Font];
    
    NSMutableAttributedString* attributedTitle = [self.signinEmailButton.titleLabel.attributedText mutableCopy];
    NSRange range = NSMakeRange(0, [attributedTitle.string length]);
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:accentColor range:range];
    
    if(font)
        [attributedTitle addAttribute:NSFontAttributeName value:font range:range];
  
    [self.signinEmailButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.buttonContainer]];
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.buttonContainer]];
    elasticityBehavior.elasticity = 0.5f;
    [self.animator addBehavior:elasticityBehavior];
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.buttonContainer]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collisionBehavior];
    
    self.facebookButton.layer.masksToBounds = YES;
    self.facebookButton.layer.cornerRadius = 40.0;
    self.facebookButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.facebookButton.layer.shouldRasterize = YES;
    self.facebookButton.clipsToBounds = YES;
    
    self.twitterButton.layer.masksToBounds = YES;
    self.twitterButton.layer.cornerRadius = 40.0;
    self.twitterButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.twitterButton.layer.shouldRasterize = YES;
    self.twitterButton.clipsToBounds = YES;
    
    self.emailButton.layer.masksToBounds = YES;
    self.emailButton.layer.cornerRadius = 40.0;
    self.emailButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.emailButton.layer.shouldRasterize = YES;
    self.emailButton.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
//    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
//    if (self.navigationController.delegate == self)
//    {
//        self.navigationController.delegate = nil;
//    }
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

#pragma mark - Actions

- (IBAction)facebookClicked:(id)sender
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:@{
                                                    ACFacebookAppIdKey: [[NSBundle mainBundle] objectForInfoDictionaryKey:kFacebookAppIDKey],
                                                    ACFacebookPermissionsKey: @[@"email"] // Needed for first login
                                                    }
                                       completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self facebookAccessDidFail:error];
            });
        }
        else
        {
            [[VUserManager sharedInstance] loginViaFacebookOnCompletion:^(VUser *user, BOOL created)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void)
                {
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
                    [self didFailWithError:error];
                });
            }];
        }
    }];
}

- (IBAction)twitterClicked:(id)sender
{
    ACAccountStore* account = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
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
                    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    [self presentViewController:composeViewController animated:NO completion:^{
                        [composeViewController dismissViewControllerAnimated:NO completion:nil];
                    }];
                });
            }
            else
            {
                [[VUserManager sharedInstance] loginViaTwitterOnCompletion:^(VUser *user, BOOL created)
                {
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
                    [self didFailWithError:error];
                }];
            }
        }
    }];
}

- (void)didFailWithError:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithFacebook"])
    {
        VProfileWithSocialViewController*   profileViewController = (VProfileWithSocialViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeFaceBook;
        profileViewController.profile = self.profile;
    }
    else if ([segue.identifier isEqualToString:@"toProfileWithTwitter"])
    {
        VProfileWithSocialViewController*   profileViewController = (VProfileWithSocialViewController *)segue.destinationViewController;
        profileViewController.loginType = kVLoginTypeTwitter;
        profileViewController.profile = self.profile;
    }
}

- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
//    VLoginTransitionAnimator*   animator = [[VLoginTransitionAnimator alloc] init];
//    animator.presenting = (operation == UINavigationControllerOperationPush);
//    return animator;
    
    return nil;
}

@end
