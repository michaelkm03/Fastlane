//
//  VLoginWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginWithEmailViewController.h"
#import "VResetCodeViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VUserManager.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"
#import "VLoginTransitionAnimator.h"
#import "THPinViewController.h"

NSString*   const   kVLoginErrorDomain =   @"VLoginErrorDomain";

@interface VLoginWithEmailViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, THPinViewControllerDelegate>
@property (nonatomic, weak) IBOutlet    UITextField*    usernameTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    passwordTextField;
@property (nonatomic, weak) IBOutlet    UIButton*       loginButton;
@property (nonatomic, weak) IBOutlet    UIButton*       cancelButton;
@property (nonatomic, weak) IBOutlet    UIButton*       forgotPasswordButton;
@property (nonatomic, strong)           VUser*          profile;
@property (nonatomic, strong)           NSString*       deviceToken;

@property (nonatomic, strong)           UIAlertView*    resetAlert;
@property (nonatomic, strong)           UIAlertView*    thanksAlert;
@property (nonatomic)                   BOOL            alertDismissed;

@end

@implementation VLoginWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPHONE_5)
        self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage5] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;
    else
        self.view.layer.contents = (id)[[[VThemeManager sharedThemeManager] themedImageForKey:kVMenuBackgroundImage] applyBlurWithRadius:25 tintColor:[UIColor colorWithWhite:1.0 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil].CGImage;

    self.usernameTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.usernameTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.usernameTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.passwordTextField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.passwordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    
    self.cancelButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
    self.cancelButton.layer.borderWidth = 2.0;
    self.cancelButton.layer.cornerRadius = 3.0;
    self.cancelButton.backgroundColor = [UIColor clearColor];
    self.cancelButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];

    self.loginButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.loginButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    [self.loginButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.forgotPasswordButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    [self.forgotPasswordButton setTitleColor:[UIColor colorWithWhite:0.14 alpha:1.0] forState:UIControlStateNormal];
    
    self.usernameTextField.delegate  =   self;
    self.passwordTextField.delegate  =   self;
    
    self.remainingPinEntries = 3;
    
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

#pragma mark - Validation

- (BOOL)shouldLoginWithUsername:(NSString *)emailAddress password:(NSString *)password
{
    NSError*    theError;
    
    if (![self validateEmailAddress:&emailAddress error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    if (![self validatePassword:&password error:&theError])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    return YES;
}

- (BOOL)validateEmailAddress:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    static  NSString *emailRegEx =
    @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    NSPredicate*  emailTest =   [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if (!(*ioValue && [emailTest evaluateWithObject:*ioValue]))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"EmailValidation", @"Invalid Email Address");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVLoginErrorDomain
                                                       code:VLoginBadEmailAddressErrorCode
                                                   userInfo:userInfoDict];
        }

        return NO;
    }

    return YES;
}

- (BOOL)validatePassword:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"PasswordValidation", @"Invalid Password");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVLoginErrorDomain
                                                       code:VLoginBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }

        return NO;
    }

    return YES;
}

#pragma mark - State

- (void)didLoginWithUser:(VUser*)mainUser
{
    VLog(@"Succesfully logged in as: %@", mainUser);
    
    self.profile = mainUser;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.alertDismissed = NO;

    self.resetAlert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword", @"")
                                                     message:NSLocalizedString(@"ResetPasswordPrompt", @"")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
                                           otherButtonTitles:NSLocalizedString(@"ResetButton", @""), nil];

    self.resetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.resetAlert textFieldAtIndex:0].placeholder = NSLocalizedString(@"ResetPasswordPlaceholder", @"");
    [self.resetAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeEmailAddress;
    [self.resetAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.resetAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            self.thanksAlert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks", @"")
                                                              message:NSLocalizedString(@"EmailSent", @"")
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
            [self.thanksAlert show];

            [[VObjectManager sharedManager] requestPasswordResetForEmail:[alertView textFieldAtIndex:0].text
                                                            successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
             {
                 self.deviceToken = resultObjects[0];
                 if (self.alertDismissed)
                     [self presentPINController];
             }
                                                               failBlock:^(NSOperation* operation, NSError* error)
             {
                 UIAlertView*   alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EmailValidation", @"")
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
            [self presentPINController];
        else
            self.alertDismissed = YES;
    }
    
}

#pragma mark - Support

- (void)presentPINController
{
    THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    pinViewController.promptTitle = @"Enter PIN";
    pinViewController.promptColor = [UIColor whiteColor];
    pinViewController.view.tintColor = [UIColor whiteColor];
    pinViewController.hideLetters = YES;
    
    pinViewController.backgroundColor = [UIColor blackColor];

    self.view.tag = THPinViewControllerContentViewTag;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    pinViewController.translucentBackground = YES;
    
    [self presentViewController:pinViewController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - THPinViewControllerDelegate

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 4;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
    return YES;
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    return YES;
}

- (void)incorrectPinEnteredInPinViewController:(THPinViewController *)pinViewController {}
- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController {}
//- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(THPinViewController *)pinViewController {}
- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(THPinViewController *)pinViewController {}
//- (void)pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:(THPinViewController *)pinViewController {}
- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController {}
//- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController {}

#pragma mark - Navigation

- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    VLoginTransitionAnimator*   animator = [[VLoginTransitionAnimator alloc] init];
    animator.presenting = (operation == UINavigationControllerOperationPush);
    return animator;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toResetCode"])
    {
        VResetCodeViewController* viewController = (VResetCodeViewController *)segue.destinationViewController;
        viewController.deviceToken = self.deviceToken;
    }
}

@end
