//
//  VSignupWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSignupWithEmailViewController.h"
#import "VProfileCreateViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VThemeManager.h"
#import "VUserManager.h"
#import "VConstants.h"
#import "UIImage+ImageEffects.h"
#import "VSignupTransitionAnimator.h"
#import "VRegistrationModel.h"
#import "VAnalyticsRecorder.h"

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, UINavigationControllerDelegate, TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet    UIButton*       cancelButton;
@property (nonatomic, weak) IBOutlet    UIButton*       signupButton;
@property (nonatomic, strong)   VUser*  profile;
@property (nonatomic, strong)   VRegistrationModel* registrationModel;
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
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:@"Started signup via email"
                                                                 action:nil
                                                                  label:nil
                                                                  value:nil];
    
    [self.emailTextField becomeFirstResponder];
    self.navigationController.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Validation

- (BOOL)shouldSignUpWithEmailAddress:(NSString *)emailAddress password:(NSString *)password
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

    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:NSLocalizedString(@"PasswordNotMatching", @"")
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
            *outError   =   [[NSError alloc] initWithDomain:kVictoriousErrorDomain
                                                       code:VSignUpBadEmailAddressErrorCode
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
            *outError   =   [[NSError alloc] initWithDomain:kVictoriousErrorDomain
                                                       code:VSignupBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }

        return NO;
    }

    return YES;
}

#pragma mark - Actions

- (IBAction)signup:(id)sender
{
    [[self view] endEditing:YES];

    if ([self shouldSignUpWithEmailAddress:self.emailTextField.text
                                  password:self.passwordTextField.text])
    {
        [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:@"Submitted email and password"
                                                                     action:nil
                                                                      label:nil
                                                                      value:nil];
        // Go to Part II of Sign-up
        [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
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
        [self.passwordTextField becomeFirstResponder];
    else if ([textField isEqual:self.passwordTextField])
        [self.confirmPasswordTextField becomeFirstResponder];
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
        VProfileCreateViewController* profileViewController = (VProfileCreateViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
        profileViewController.loginType = kVLoginTypeEmail;
        self.registrationModel.email = self.emailTextField.text;
        self.registrationModel.password = self.passwordTextField.text;
        profileViewController.registrationModel = self.registrationModel;
    }
}

- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    VSignupTransitionAnimator*   animator = [[VSignupTransitionAnimator alloc] init];
    animator.presenting = (operation == UINavigationControllerOperationPush);
    return animator;
}

@end
