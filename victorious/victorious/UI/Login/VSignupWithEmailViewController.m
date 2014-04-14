//
//  VSignupWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSignupWithEmailViewController.h"
#import "VProfileWithEmailViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "TTTAttributedLabel.h"
#import "VThemeManager.h"
#import "VUserManager.h"

NSString*   const   kSignupErrorDomain =   @"VSignupErrorDomain";

@interface VSignupWithEmailViewController ()    <UITextFieldDelegate, TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch* agreeSwitch;
@property (nonatomic, weak) IBOutlet    TTTAttributedLabel* agreementText;
@property (nonatomic, strong)   VUser*  profile;
@end

@implementation VSignupWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usernameTextField.delegate =   self;
    self.passwordTextField.delegate =   self;
    self.emailTextField.delegate =   self;

    [self.usernameTextField becomeFirstResponder];

    self.agreementText.delegate = self;
    [self.agreementText setText:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementText]];
    NSRange linkRange = [self.agreementText.text rangeOfString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLinkText]];
    if (linkRange.length > 0)
    {
        NSURL *url = [NSURL URLWithString:[[VThemeManager sharedThemeManager] themedStringForKey:kVAgreementLink]];
        [self.agreementText addLinkToURL:url withRange:linkRange];
    }
}

#pragma mark - Validation

- (BOOL)shouldSignUpWithUsername:(NSString *)username emailAddress:(NSString *)emailAddress password:(NSString *)password
{
    NSError*    theError;

    if (![self validateUsername:&username error:&theError])
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

    if (NO == self.agreeSwitch.on)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:NSLocalizedString(@"AgreeTOS", @"")
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }

    return YES;
}

- (BOOL)validateUsername:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"UsernameValidation", @"Invalid Username");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kSignupErrorDomain
                                                       code:VSignupBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }

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
            *outError   =   [[NSError alloc] initWithDomain:kSignupErrorDomain
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
            *outError   =   [[NSError alloc] initWithDomain:kSignupErrorDomain
                                                       code:VSignupBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }

        return NO;
    }

    return YES;
}

#pragma mark - State

- (void)didSignUpWithUser:(VUser*)mainUser
{
    self.profile = mainUser;

    [self performSegueWithIdentifier:@"toProfileWithEmail" sender:self];
}

- (void)didFailWithError:(NSError*)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    [[self view] endEditing:YES];

    if (YES == [self shouldSignUpWithUsername:self.usernameTextField.text
                                 emailAddress:self.emailTextField.text
                                     password:self.passwordTextField.text])
    {
        
        [[VUserManager sharedInstance] createEmailAccount:self.emailTextField.text
                                                 password:self.passwordTextField.text
                                                 userName:self.usernameTextField.text
                                             onCompletion:^(VUser *user, BOOL created)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [self didSignUpWithUser:user];
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
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
        [self.emailTextField becomeFirstResponder];
    else if ([textField isEqual:self.emailTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self.passwordTextField resignFirstResponder];
    
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
        VProfileWithEmailViewController* profileViewController = (VProfileWithEmailViewController *)segue.destinationViewController;
        profileViewController.profile = self.profile;
    }
}

@end
