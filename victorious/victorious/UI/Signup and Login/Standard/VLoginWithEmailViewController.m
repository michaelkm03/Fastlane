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
#import "VDependencyManager.h"
#import "UIImage+ImageEffects.h"
#import "UIAlertView+VBlocks.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
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

@property (nonatomic, strong) VLinkTextViewHelper *linkTextHelper;
@property (nonatomic, strong) IBOutlet CCHLinkTextView *forgotPasswordTextView;

@end

@implementation VLoginWithEmailViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.usernameTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    
    self.usernameTextField.delegate = nil;
    self.passwordTextField.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.linkTextHelper = [[VLinkTextViewHelper alloc] initWithDependencyManager:self.dependencyManager];
    
    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.usernameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    
    [self.usernameTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.usernameTextField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.usernameTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.usernameTextField.delegate = self;
    
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"Password character requirement.")
                                                                               attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.passwordTextField.delegate = self;
    
    self.cancelButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    self.cancelButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.cancelButton.style = VButtonStyleSecondary;

    self.loginButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    self.loginButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
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
    NSString *text = [NSString stringWithFormat:@"%@ %@", normalText, linkText];
    NSRange range = [text rangeOfString:linkText];
    self.forgotPasswordTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
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
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self forgotPassword:nil];
}

#pragma mark - Validation

- (BOOL)shouldLogin
{
    NSError *validationError;
    BOOL shouldLogin = YES;
    id newResponder = nil;
    
    if (![self.emailValidator validateString:self.usernameTextField.text andError:&validationError])
    {
        [self.usernameTextField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        shouldLogin = NO;
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailValidationDidFail parameters:params];
        
        if (newResponder == nil)
        {
            [self.usernameTextField becomeFirstResponder];
            newResponder = self.usernameTextField;
        }
    }
    
    if ( ![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError])
    {
        
        [self.passwordTextField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        shouldLogin = NO;
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailValidationDidFail parameters:params];
        
        if (newResponder == nil)
        {
            [self.passwordTextField becomeFirstResponder];
        }
    }
    
    return shouldLogin;
}

#pragma mark - State

- (void)didLoginWithUser:(VUser *)mainUser
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidSucceed];
    
    self.profile = mainUser;
    
    if ( self.registrationStepDelegate != nil )
    {
        [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:YES];
    }
}

- (void)didFailWithError:(NSError *)error
{
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailDidFail parameters:params];
    
    if (error.code != kVUserBannedError)
    {
        NSString *message = NSLocalizedString(@"GenericFailMessage", @"");
        
        if ( error.code == kVUserOrPasswordInvalidError )
        {
            message = NSLocalizedString(@"Invalid email address or password", @"");
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Actions

- (IBAction)login:(id)sender
{
    [[self view] endEditing:YES];

    if ([self shouldLogin])
    {
        self.loginButton.enabled = NO;
        [self performLoginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    }
}

- (void)performLoginWithUsername:(NSString *)username password:(NSString *)password
{
    [[VUserManager sharedInstance] loginViaEmail:username
                                        password:password
                                    onCompletion:^(VUser *user, BOOL created)
     {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                            [self didLoginWithUser:user];
                        });
     }
                                         onError:^(NSError *error, BOOL thirdPartyAPIFailed)
     {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                            [self didFailWithError:error];
                            self.loginButton.enabled = YES;
                        });
     }];
}

- (IBAction)cancel:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelLoginWithEmail];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgotPassword:(id)sender
{
    [[self view] endEditing:YES];
    self.alertDismissed = NO;
    
    self.resetAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword", @"")
                                                 message:NSLocalizedString(@"ResetPasswordPrompt", @"")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                       otherButtonTitles:NSLocalizedString(@"ResetButton", @""), nil];

    self.resetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.resetAlert textFieldAtIndex:0].placeholder = NSLocalizedString(@"ResetPasswordPlaceholder", @"");
    [self.resetAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [self.resetAlert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
    [self.resetAlert show];
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectResetPassword];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.resetAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSString *emailEntered = [alertView textFieldAtIndex:0].text;
            if ( emailEntered == nil || emailEntered.length == 0 )
            {
                NSString *message = NSLocalizedString(@"EmailNotValid", @"");
                NSString *title = NSLocalizedString(@"EmailValidation", @"");
                [self showInvalidEmailForResetPasswordErrorWithMessage:message title:title];
                
                NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
                [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordValidationDidFail parameters:params];
                return;
            }
            
            [[VObjectManager sharedManager] requestPasswordResetForEmail:emailEntered
                                                            successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 self.deviceToken = resultObjects[0];
                 [self performSegueWithIdentifier:@"toEnterResetToken" sender:self];
             }
                                                               failBlock:^(NSOperation *operation, NSError *error)
             {
                 NSString *message = NSLocalizedString(@"EmailNotFound", @"");
                 NSString *title = NSLocalizedString(@"EmailValidation", @"");
                 
                 NSDictionary *params = @{ VTrackingKeyErrorMessage : message ?: @"" };
                 [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordDidFail parameters:params];
                 
                 [self showInvalidEmailForResetPasswordErrorWithMessage:message title:title];
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

- (void)showInvalidEmailForResetPasswordErrorWithMessage:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [alert show];
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

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VRegistrationModel *registrationModelForUser = [VRegistrationModel registrationModelWithUser:self.profile];
    if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
        profileViewController.loginType = VLoginTypeEmail;
        profileViewController.registrationModel = registrationModelForUser;
        profileViewController.dependencyManager = self.dependencyManager;
        profileViewController.registrationStepDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"toEnterResetToken"])
    {
        VEnterResetTokenViewController *destinationVC = (VEnterResetTokenViewController *)segue.destinationViewController;
        destinationVC.registrationStepDelegate = self;
        destinationVC.deviceToken = self.deviceToken;
        destinationVC.dependencyManager = self.dependencyManager;
    }
}

#pragma mark - Private Methods

- (void)validateWithTextField:(VInlineValidationTextField *)textField
{
    NSError *validationError;
    
    if (textField == self.usernameTextField)
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
}

#pragma mark - VRegistrationStepDelegate

- (void)didFinishRegistrationStepWithSuccess:(BOOL)success
{
    [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:success];
}

@end
