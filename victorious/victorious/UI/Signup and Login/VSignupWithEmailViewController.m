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
#import "VInlineValidationTextField.h"

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, UINavigationControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailTextField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *confirmPasswordTextField;
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
    [self.emailTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
        UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.emailTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName: activePlaceholderColor}];

    self.passwordTextField.validator = [[VPasswordValidator alloc] init];
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"") attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    
    self.confirmPasswordTextField.validator = [[VPasswordValidator alloc] init];
    [self.confirmPasswordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"") attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    
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
        self.emailTextField.showInlineValidation = YES;
        [self.emailTextField becomeFirstResponder];
        [self.emailTextField showIncorrectTextAnimationAndVibration];
        return NO;
    }

    [self.confirmPasswordTextField.validator setConfirmationObject:self.confirmPasswordTextField
                                                       withKeyPath:NSStringFromSelector(@selector(text))];
    if (![self.passwordValidator validateString:self.passwordTextField.text
                                       andError:&validationError])
    {
        if (validationError.code == VErrorCodeInvalidPasswordsDoNotMatch)
        {
            self.confirmPasswordTextField.showInlineValidation = YES;
            [self.confirmPasswordTextField showIncorrectTextAnimationAndVibration];
        }
        else
        {
            self.passwordTextField.showInlineValidation = YES;
            [self.passwordTextField showIncorrectTextAnimationAndVibration];
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

- (BOOL)textFieldShouldReturn:(VInlineValidationTextField *)textField
{
    if (![textField.validator validateString:textField.text
                                    andError:nil])
    {
        [textField showIncorrectTextAnimationAndVibration];
        textField.showInlineValidation = YES;
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
            [textField showIncorrectTextAnimationAndVibration];
            textField.showInlineValidation = YES;
            return NO;
        }
        [self signup:textField];
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL validEmail = [self.emailTextField.validator validateString:self.emailTextField.text
                                                           andError:nil];
    if ([self.emailTextField isFirstResponder] && !validEmail)
    {
        self.emailTextField.showInlineValidation = YES;
        [self.emailTextField showIncorrectTextAnimationAndVibration];
    }
    
    BOOL validPassword = [self.passwordTextField.validator validateString:self.passwordTextField.text
                                                              andError:nil];
    if ([self.passwordTextField isFirstResponder] && !validPassword)
    {
        self.passwordTextField.showInlineValidation = YES;
        [self.passwordTextField showIncorrectTextAnimationAndVibration];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (textField == self.passwordTextField)
    {
        self.confirmPasswordTextField.text = nil;
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

@end
