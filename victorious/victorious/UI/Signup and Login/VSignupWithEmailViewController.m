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
#import "VButton.h"
#import "VTextField.h"

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, UINavigationControllerDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet VTextField *emailTextField;
@property (weak, nonatomic) IBOutlet VTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet VTextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet    VButton       *cancelButton;
@property (nonatomic, weak) IBOutlet    VButton       *signupButton;
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

    self.cancelButton.style = VButtonStyleSecondary;
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.signupButton.style = VButtonStylePrimary;
    self.signupButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.signupButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.emailTextField.validator = [[VEmailValidator alloc] init];
    self.emailTextField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.emailTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.emailTextField.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];

    self.passwordTextField.validator = [[VPasswordValidator alloc] init];
    self.passwordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.passwordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.confirmPasswordTextField.validator = [[VPasswordValidator alloc] init];
    self.confirmPasswordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.confirmPasswordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

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

    if (![self.emailValidator validateString:emailAddress
                                    andError:&validationError])
    {
        [self.emailTextField incorrectTextAnimationAndVibration];
        return NO;
    }

    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                      withKeyPath:NSStringFromSelector(@selector(text))];
    if (![self.passwordValidator validateString:self.passwordTextField.text
                                       andError:&validationError])
    {
        if (validationError.code == VErrorCodeInvalidPasswordsDoNotMatch)
        {
            [self.confirmPasswordTextField incorrectTextAnimationAndVibration];
        }
        else
        {
            [self.passwordTextField incorrectTextAnimationAndVibration];
        }
        
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

- (BOOL)textFieldShouldReturn:(VTextField *)textField
{
    if (![textField.validator validateString:textField.text
                                    andError:nil])
    {
        [textField incorrectTextAnimationAndVibration];
        textField.showInlineValidation = YES;
        return NO;
    }
    
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
        [textField.validator setConfirmationObject:self.passwordTextField
                                       withKeyPath:NSStringFromSelector(@selector(text))];
        if (![textField.validator validateString:textField.text
                                        andError:nil])
        {
            [textField incorrectTextAnimationAndVibration];
            textField.showInlineValidation = YES;
            return NO;
        }
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
