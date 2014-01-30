//
//  VLoginWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginWithEmailViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Login.h"
#import "VUser.h"

NSString*   const   kVLoginErrorDomain =   @"VLoginErrorDomain";

@interface VLoginWithEmailViewController () <UITextFieldDelegate>
@property   (nonatomic, weak)   IBOutlet    UITextField*    usernameTextField;
@property   (nonatomic, weak)   IBOutlet    UITextField*    passwordTextField;
@property   (nonatomic, strong)             VUser*          profile;
@end

@implementation VLoginWithEmailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.layer.contents = (id)[UIImage imageNamed:@"loginBackground"].CGImage;
    
    self.usernameTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emailImage"]];
    self.usernameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passwordImage"]];
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;

    self.usernameTextField.delegate  =   self;
    self.passwordTextField.delegate  =   self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginChanged:)
                                                 name:kLoggedInChangedNotification
                                               object:nil];
}

- (void)loginChanged:(NSNotification *)notification
{
    VUser* mainuser = notification.object;
    [VObjectManager sharedManager].mainUser = mainuser;

    // Display failed login is the blob isnt a user or if it has no token
    if ( (mainuser && ![mainuser isKindOfClass:[VUser class]]) || (mainuser && !mainuser.token) )
    {
        [VObjectManager sharedManager].mainUser = nil;
        [self didFailWithError:nil];
        VLog(@"Invalid object passed in loginChanged notification: %@", mainuser);
        return;
    }

    if (mainuser)
    {
        // We've logged in
        [[VObjectManager sharedManager] loadNextPageOfConversations:nil failBlock:nil];
        [[VObjectManager sharedManager] pollResultsForUser:mainuser successBlock:nil failBlock:nil];
        [[VObjectManager sharedManager] unreadCountForConversationsWithSuccessBlock:nil failBlock:nil];
    }
    else
    {
        // We've logged out
        [VObjectManager sharedManager].mainUser = nil;
    }
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

    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInChangedNotification object:mainUser];
    
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
        VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            if (![[resultObjects firstObject] isKindOfClass:[VUser class]])
                [self didFailWithError:nil];
            
            [self didLoginWithUser:[resultObjects firstObject]];
        };
        VFailBlock fail = ^(NSOperation* operation, NSError* error)
        {
            [self didFailWithError:error];
            VLog(@"Error in victorious Login: %@", error);
        };
        
        [[VObjectManager sharedManager] loginToVictoriousWithEmail:self.usernameTextField.text
                                                          password:self.passwordTextField.text
                                                      successBlock:success
                                                         failBlock:fail];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
        [self.passwordTextField becomeFirstResponder];
    else
        [self.passwordTextField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
