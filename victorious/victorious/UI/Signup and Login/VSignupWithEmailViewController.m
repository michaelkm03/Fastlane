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

@property (nonatomic, strong) VEmailValidator *emailValidator;
@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VSignupWithEmailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.confirmPasswordTextField];
    
    self.emailTextField.delegate = nil;
    self.passwordTextField.delegate = nil;
    self.confirmPasswordTextField.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.emailTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.confirmPasswordTextField];

    self.cancelButton.style = VButtonStyleSecondary;
    self.cancelButton.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.signupButton.style = VButtonStylePrimary;
    self.signupButton.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.signupButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    
    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [self.emailTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
        UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.emailTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.emailTextField.placeholder attributes:@{NSForegroundColorAttributeName: activePlaceholderColor}];
    self.emailTextField.delegate = self;
    
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"") attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.passwordTextField.delegate = self;
    
    [self.confirmPasswordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"") attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.confirmPasswordTextField.delegate = self;
    
    self.registrationModel = [[VRegistrationModel alloc] init];
    
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

- (BOOL)shouldSignUp
{
    NSError *validationError;
    BOOL shouldSignup = YES;
    id newResponder = nil;
    
    if (![self.emailValidator validateString:self.emailTextField.text andError:&validationError])
    {
        [self.emailTextField showInvalidText:validationError.localizedDescription
                                    animated:YES
                                       shake:YES
                                      forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.emailTextField becomeFirstResponder];
        newResponder = self.emailTextField;
    }
    
    [self.passwordValidator setConfirmationObject:nil
                                      withKeyPath:nil];
    if (![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError])
    {
        [self.passwordTextField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        if (newResponder == nil)
        {
            [self.passwordTextField becomeFirstResponder];
            newResponder = self.passwordTextField;
        }
    }
    
    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                      withKeyPath:NSStringFromSelector(@selector(text))];
    if (![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError])
    {
        [self.confirmPasswordTextField showInvalidText:validationError.localizedDescription
                                              animated:YES
                                                 shake:YES
                                                forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        if (newResponder == nil)
        {
            [self.confirmPasswordTextField becomeFirstResponder];
        }
    }

    return shouldSignup;
}

#pragma mark - State

- (void)didSignUpWithUser:(VUser *)mainUser
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidSucceed];
    
    self.profile = mainUser;
    
    // Go to Part II of Sign-up
    [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
}

- (void)didFailWithError:(NSError *)error
{
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidFail parameters:params];
    
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

    if ([self shouldSignUp])
    {
        // Let the User Know Something Is Happening
        [MBProgressHUD showHUDAddedTo:self.view
                             animated:YES];
        
        self.registrationModel.email = self.emailTextField.text;
        self.registrationModel.password = self.passwordTextField.text;
        
        [[VUserManager sharedInstance] createEmailAccount:self.registrationModel.email
                                                 password:self.registrationModel.password
                                                 userName:nil
                                             onCompletion:^(VUser *user, BOOL created)
         {
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
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelSignupWithEmail];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    VInlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(VInlineValidationTextField *)textField
{
    if ( textField.text.length > 0 )
    {
        [self validateWithTextField:textField];
    }
    return YES;
}

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

#pragma mark - Private Methods

- (void)validateWithTextField:(VInlineValidationTextField *)textField
{
    NSError *validationError;
    
    if (textField == self.emailTextField)
    {
        BOOL validEmail = [self.emailValidator validateString:textField.text
                                                     andError:&validationError];
        if (!validEmail)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordValidator setConfirmationObject:nil
                                          withKeyPath:nil];
        BOOL validPassword = [self.passwordValidator validateString:textField.text
                                                           andError:&validationError];
        if (!validPassword)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
    if (textField == self.confirmPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                          withKeyPath:NSStringFromSelector(@selector(text))];
        BOOL validConfimration = [self.passwordValidator validateString:self.passwordTextField.text
                                                               andError:&validationError];
        if (!validConfimration)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
            [self.passwordTextField hideInvalidText];
        }
    }
}

@end
