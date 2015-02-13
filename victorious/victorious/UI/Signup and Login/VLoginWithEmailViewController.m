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
#import "VInlineValidationTextField.h"

@interface VLoginWithEmailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet    VInlineValidationTextField     *usernameTextField;
@property (nonatomic, weak) IBOutlet    VInlineValidationTextField     *passwordTextField;
@property (nonatomic, weak) IBOutlet    UIButton       *loginButton;
@property (nonatomic, weak) IBOutlet    UIButton       *cancelButton;
@property (nonatomic, weak) IBOutlet    UIButton       *forgotPasswordButton;
@property (nonatomic, strong)           VUser          *profile;
@property (nonatomic, strong)           NSString       *deviceToken;
@property (nonatomic, strong)           NSString       *userToken;

@property (nonatomic, strong)           UIAlertView    *resetAlert;
@property (nonatomic, strong)           UIAlertView    *thanksAlert;
@property (nonatomic)                   BOOL            alertDismissed;

@property (nonatomic, strong)           VEmailValidator *emailValidator;
@property (nonatomic, strong)           VPasswordValidator *passwordValidator;

@end

@implementation VLoginWithEmailViewController

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

    self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;

    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.usernameTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    
    [self.usernameTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    self.usernameTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.usernameTextField.delegate = self;
    
    [self.passwordTextField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 Characters", @"Password character requirement.")
                                                                               attributes:@{NSForegroundColorAttributeName : activePlaceholderColor}];
    self.passwordTextField.delegate = self;
    
    self.cancelButton.layer.borderColor = [UIColor colorWithWhite:0.14 alpha:1.0].CGColor;
    self.cancelButton.layer.borderWidth = 2.0;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];

    self.loginButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.loginButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.forgotPasswordButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    [self.forgotPasswordButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.usernameTextField.delegate  =   self;
    self.passwordTextField.delegate  =   self;
    
    self.usernameTextField.accessibilityIdentifier = VAutomationIdentifierLoginUsernameField;
    self.passwordTextField.accessibilityIdentifier = VAutomationIdentifierLoginPasswordField;
    self.forgotPasswordButton.accessibilityIdentifier = VAutomationIdentifierLoginForgotPassword;
    self.cancelButton.accessibilityIdentifier = VAutomationIdentifierLoginCancel;
    self.loginButton.accessibilityIdentifier = VAutomationIdentifierLoginSubmit;
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
    self.emailValidator = [[VEmailValidator alloc] init];
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

    if ([self shouldLogin])
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

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    VInlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(VInlineValidationTextField *)textField
{
    [self validateWithTextField:textField];
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
    if ([segue.identifier isEqualToString:@"toProfileWithEmail"])
    {
        VProfileCreateViewController *profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
        profileViewController.loginType = kVLoginTypeEmail;
        profileViewController.registrationModel = [[VRegistrationModel alloc] init];
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

@end
