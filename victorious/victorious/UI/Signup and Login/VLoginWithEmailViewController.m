//
//  VLoginWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginWithEmailViewController.h"
#import "VLoginViewController.h"
#import "VProfileCreateViewController.h"
#import "VResetPasswordViewController.h"
#import "VEnterResetTokenViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "UIAlertView+VBlocks.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VAutomation.h"
#import "VButton.h"
#import "VInlineValidationTextField.h"

#import "CCHLinkTextView.h"
#import "VLinkTextViewHelper.h"
#import "CCHLinkTextViewDelegate.h"

@interface VLoginWithEmailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, CCHLinkTextViewDelegate>

@property (nonatomic, weak) IBOutlet VInlineValidationTextField *usernameTextField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet VButton *loginButton;
@property (nonatomic, weak) IBOutlet VButton *cancelButton;

@property (nonatomic, strong) VUser *profile;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userToken;

@property (nonatomic, strong) UIAlertView *resetAlert;
@property (nonatomic, strong) UIAlertView *thanksAlert;
@property (nonatomic) BOOL alertDismissed;

@property (nonatomic, strong) VPasswordValidator *passwordValidator;
@property (nonatomic, strong) VEmailValidator *emailValidator;

@property (nonatomic, strong) IBOutlet VLinkTextViewHelper *linkTextHelper;
@property (nonatomic, strong) IBOutlet CCHLinkTextView *forgotPasswordTextView;

@end

@implementation VLoginWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;

    self.usernameTextField.validator = [[VEmailValidator alloc] init];
    [self.usernameTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.usernameTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    
    self.passwordTextField.validator = [[VPasswordValidator alloc] init];
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 Characters", @"Password character requirement.")
                                                                               attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.cancelButton.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.cancelButton.style = VButtonStyleSecondary;

    self.loginButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.loginButton.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.loginButton.style = VButtonStylePrimary;
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.usernameTextField.accessibilityIdentifier = VAutomationIdentifierLoginUsernameField;
    self.passwordTextField.accessibilityIdentifier = VAutomationIdentifierLoginPasswordField;
    self.cancelButton.accessibilityIdentifier = VAutomationIdentifierLoginCancel;
    self.loginButton.accessibilityIdentifier = VAutomationIdentifierLoginSubmit;
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
    self.emailValidator = [[VEmailValidator alloc] init];
    
    NSString *linkText = NSLocalizedString( @"Reset here", @"" );
    NSString *normalText = NSLocalizedString( @"Forgot Password?", @"" );
    NSString *text = [NSString stringWithFormat:NSLocalizedString( @"%@ %@", @""), normalText, linkText];
    NSRange range = [text rangeOfString:linkText];
    self.forgotPasswordTextView.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    [self.linkTextHelper setupLinkTextView:self.forgotPasswordTextView withText:text range:range];
    self.forgotPasswordTextView.linkDelegate = self;
    self.forgotPasswordTextView.accessibilityIdentifier = VAutomationIdentifierLoginForgotPassword;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameTextField becomeFirstResponder];
    self.navigationController.delegate = self;
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self performSegueWithIdentifier:@"toEnterResetToken" sender:self];
}

#pragma mark - Validation

- (BOOL)shouldLoginWithUsername:(NSString *)emailAddress password:(NSString *)password
{
    NSError *validationError;
    
    if (![self.emailValidator validateString:emailAddress andError:&validationError])
    {
        self.usernameTextField.showInlineValidation = YES;
        [self.usernameTextField validateTextWithValidator:self.emailValidator];
        [self.usernameTextField showIncorrectTextAnimationAndVibration];
        [self.usernameTextField becomeFirstResponder];
        return NO;
    }
    
    if ( ![self.passwordValidator validateString:password andError:&validationError] )
    {
        self.passwordTextField.showInlineValidation = YES;
        [self.passwordTextField validateTextWithValidator:self.passwordValidator];
        [self.passwordTextField showIncorrectTextAnimationAndVibration];
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - State

- (void)didLoginWithUser:(VUser *)mainUser
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidSucceed];
    
    self.profile = mainUser;
    
    if ( ![VObjectManager sharedManager].authorized )
    {
        [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didFailWithError:(NSError *)error
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidFail];
    if (error.code != kVUserBannedError)
    {
        NSString       *message = [error.domain isEqualToString:kVictoriousErrorDomain] ? error.localizedDescription
                                            : NSLocalizedString(@"LoginFailMessage", @"");
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    [[self view] endEditing:YES];

    if ([self shouldLoginWithUsername:self.usernameTextField.text password:self.passwordTextField.text])
    {
        self.loginButton.enabled = NO;
        [[VUserManager sharedInstance] loginViaEmail:self.usernameTextField.text
                                             password:self.passwordTextField.text
                                         onCompletion:^(VUser *user, BOOL created)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self didLoginWithUser:user];
            });
        }
                                              onError:^(NSError *error)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                [self didFailWithError:error];
                self.loginButton.enabled = YES;
            });
        }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

 -(IBAction)forgotPassword:(id)sender
{
    [[self view] endEditing:YES];
    self.alertDismissed = NO;

    self.resetAlert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword", @"")
                                                     message:NSLocalizedString(@"ResetPasswordPrompt", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                           otherButtonTitles:NSLocalizedString(@"ResetButton", @""), nil];

    self.resetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.resetAlert textFieldAtIndex:0].placeholder = NSLocalizedString(@"ResetPasswordPlaceholder", @"");
    [self.resetAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [self.resetAlert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [self.resetAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.resetAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSString *emailEntered = [alertView textFieldAtIndex:0].text;
            [[VObjectManager sharedManager] requestPasswordResetForEmail:emailEntered
                                                            successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 self.deviceToken = resultObjects[0];
                 [self performSegueWithIdentifier:@"toEnterResetToken" sender:self];
             }
                                                               failBlock:^(NSOperation *operation, NSError *error)
             {
                 UIAlertView   *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailValidation", @"")
                                                                       message:NSLocalizedString(@"EmailNotFound", @"")
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
                 [alert show];
             }];
        }
    }
    else if (alertView == self.thanksAlert)
    {
        if (self.deviceToken)
        {
            [self performSegueWithIdentifier:@"toEnterResetToken" sender:self];
        }
        else
        {
            self.alertDismissed = YES;
        }
    }
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
    
    if (textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self.passwordTextField resignFirstResponder];
        [self login:nil];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL validUsername = [self.usernameTextField.validator validateString:self.usernameTextField.text
                                                                 andError:nil];

    if ([self.usernameTextField isFirstResponder] && !validUsername)
    {
        self.usernameTextField.showInlineValidation = YES;
    }
    
    BOOL validPassword = [self.passwordTextField.validator validateString:self.passwordTextField.text
                                                              andError:nil];
    if ([self.passwordTextField isFirstResponder] && !validPassword)
    {
        self.passwordTextField.showInlineValidation = YES;
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
        profileViewController.loginType = kVLoginTypeEmail;
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
    }
}

@end
