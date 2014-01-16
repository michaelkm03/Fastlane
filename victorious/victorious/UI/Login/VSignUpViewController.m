//
//  VEmailLoginViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/5/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VSignUpViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"

NSString*   const   kSignupViewControllerDomain =   @"VSignupViewControllerDomain";


@interface      VSignUpViewController   ()  <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch* agreeSwitch;
@end

@implementation VSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usernameTextField.delegate =   self;
    self.passwordTextField.delegate =   self;
    self.emailTextField.delegate =   self;
    
    [self.usernameTextField becomeFirstResponder];
}

#pragma mark -

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

- (void)didSignUpWithUser:(VUser*)mainUser
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LoggedInChangedNotification
                                                        object:mainUser];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFailToSignUp:(NSError *)error
{
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                           message:error.localizedDescription
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                 otherButtonTitles:nil];
    [alert show];
}

- (void)didCancelSignUp
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateUsername:(id *)ioValue error:(NSError * __autoreleasing *)outError
{
    if ((*ioValue == nil) || ([(NSString *)*ioValue length] < 8))
    {
        if (outError != NULL)
        {
            NSString *errorString = NSLocalizedString(@"UsernameValidation", @"Invalid Username");
            NSDictionary*   userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kSignupViewControllerDomain
                                                       code:VSignupViewControllerBadPasswordErrorCode
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
            *outError   =   [[NSError alloc] initWithDomain:kSignupViewControllerDomain
                                                       code:VSignUpViewControllerBadEmailAddressErrorCode
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
            *outError   =   [[NSError alloc] initWithDomain:kSignupViewControllerDomain
                                                       code:VSignupViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (IBAction)signup:(id)sender
{
    [[self view] endEditing:YES];

    if (YES == [self shouldSignUpWithUsername:self.usernameTextField.text
                                 emailAddress:self.emailTextField.text
                                     password:self.passwordTextField.text])
    {
        SuccessBlock success = ^(NSArray* objects)
        {
            VUser* mainUser = [objects firstObject];
            if (![mainUser isKindOfClass:[VUser class]])
            {
                VLog(@"Invalid user object returned in api/account/create");
                [self didFailToSignUp:nil];
                return;
            }
            
            [self didSignUpWithUser:mainUser];
        };

        FailBlock fail = ^(NSError* error)
        {
            [self didFailToSignUp:error];
        };
        [[VObjectManager sharedManager] createVictoriousWithEmail:self.emailTextField.text
                                                          password:self.passwordTextField.text
                                                          username:self.usernameTextField.text
                                                      successBlock:success
                                                         failBlock:fail];
    }
}

- (IBAction)cancelClicked:(id)sender
{
    [self didCancelSignUp];
}

#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
        [self.emailTextField becomeFirstResponder];
    else if ([textField isEqual:self.emailTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self signup:self];
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
