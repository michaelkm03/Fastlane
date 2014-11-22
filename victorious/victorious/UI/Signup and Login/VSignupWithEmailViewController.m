//
//  VSignupWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSignupWithEmailViewController.h"
#import "VProfileCreateViewController.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VThemeManager.h"
#import "VUserManager.h"
#import "VConstants.h"
#import "UIImage+ImageEffects.h"
#import "VSignupTransitionAnimator.h"
#import "VRegistrationModel.h"
#import "MBProgressHUD.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VAutomation.h"

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, UINavigationControllerDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet    UIButton       *cancelButton;
@property (nonatomic, weak) IBOutlet    UIButton       *signupButton;
@property (nonatomic, strong)   VUser  *profile;
@property (nonatomic, strong)   VRegistrationModel *registrationModel;
@property (nonatomic, strong)   VPasswordValidator *passwordValidator;
@property (nonatomic, strong)   VEmailValidator *emailValidator;

@end

@implementation VSignupWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;

    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;

    self.cancelButton.layer.borderColor = [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;
    self.cancelButton.layer.borderWidth = 2.0;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.signupButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.signupButton.layer.cornerRadius = 3.0;
    self.signupButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.emailTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.emailTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.passwordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.confirmPasswordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];

    self.registrationModel = [[VRegistrationModel alloc] init];
    
    // Validators
    self.passwordValidator = [[VPasswordValidator alloc] init];
    self.emailValidator = [[VEmailValidator alloc] init];
    
    // Accessibility IDs
    self.cancelButton.accessibilityIdentifier = VAutomationIdentifierSignupCancel;
    self.signupButton.accessibilityIdentifier = VAutomationIdentifierSignupSubmit;
    self.emailTextField.accessibilityIdentifier = VAutomationIdentifierSignupUsernameField;
    self.passwordTextField.accessibilityIdentifier = VAutomationIdentifierSignupPasswordField;
    self.confirmPasswordTextField.accessibilityIdentifier = VAutomationIdentifierSignupPasswordConfirmField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectSignupWithEmail];
    
    [self.emailTextField becomeFirstResponder];
    self.navigationController.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Validation

- (BOOL)shouldSignUpWithEmailAddress:(NSString *)emailAddress password:(NSString *)password
{
    NSError *validationError;

    if (![self.emailValidator validateEmailAddress:emailAddress error:&validationError])
    {
        [self.emailValidator showAlertInViewController:self withError:validationError];
        return NO;
    }

    if (![self.passwordValidator validatePassword:self.passwordTextField.text
                                 withConfirmation:self.confirmPasswordTextField.text
                                            error:&validationError] )
    {
        [self.passwordValidator showAlertInViewController:self withError:validationError];
        return NO;
    }
    
    return YES;
}

#pragma mark - State

- (void)didSignUpWithUser:(VUser *)mainUser
{
    self.profile = mainUser;
    
    // Go to Part II of Sign-up
    [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
}

- (void)didFailWithError:(NSError *)error
{
    
    UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
    
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

#pragma mark - Actions

- (IBAction)signup:(id)sender
{
    [[self view] endEditing:YES];

    if ([self shouldSignUpWithEmailAddress:self.emailTextField.text
                                  password:self.passwordTextField.text])
    {
        // Let the User Know Something Is Happening
        [MBProgressHUD showHUDAddedTo:self.view
                             animated:YES];
        
        self.registrationModel.email = self.emailTextField.text;
        self.registrationModel.password = self.passwordTextField.text;
        
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSubmitSignupInfo];
        
        [[VUserManager sharedInstance] createEmailAccount:self.registrationModel.email
                                                 password:self.registrationModel.password
                                                 userName:nil
                                             onCompletion:^(VUser *user, BOOL created)
         {
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidSucceed];
             [self didSignUpWithUser:user];
         }
                                                  onError:^(NSError *error)
         {
             [self didFailWithError:error];
         }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextField])
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordTextField])
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else
    {
        [self signup:textField];
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
        profileViewController.loginType = kVLoginTypeEmail;
        profileViewController.registrationModel = self.registrationModel;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    VSignupTransitionAnimator   *animator = [[VSignupTransitionAnimator alloc] init];
    animator.presenting = (operation == UINavigationControllerOperationPush);
    return animator;
}

@end
