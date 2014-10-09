//
//  VChangePasswordViewController.m
//  victorious
//
//  Created by Gary Philipp on 6/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VChangePasswordViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VThemeManager.h"
#import "VConstants.h"

@interface VChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *changedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@end

@implementation VChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.oldPasswordTextField.delegate =   self;
    self.changedPasswordTextField.delegate =   self;
    self.confirmPasswordTextField.delegate =   self;
    
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0].CGColor;

    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
     }];
    [self.textFields enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop)
     {
         label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
     }];
}

#pragma mark - Validation

- (BOOL)shouldUpdatePassword:(NSString *)password confirmation:(NSString *)confirmationPassword
{
    NSError *theError;
    
    if (![self validatePassword:password error:&theError])
    {
        UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                               message:theError.localizedDescription
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                     otherButtonTitles:nil];
        [alert show];
        [[self view] endEditing:YES];
        return NO;
    }
    
    if (![password isEqualToString:confirmationPassword])
    {
        UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                           message:NSLocalizedString(@"PasswordNotMatching", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
        [alert show];
        return NO;
    }
    
    
    return YES;
}

- (BOOL)validatePassword:(NSString *)password error:(NSError **)outError
{
    if ( password == nil || password.length < 8 )
    {
        if ( outError != nil )
        {
            NSString *errorString = NSLocalizedString(@"PasswordValidation", @"Invalid Password");
            NSDictionary   *userInfoDict = @{ NSLocalizedDescriptionKey : errorString };
            *outError   =   [[NSError alloc] initWithDomain:kVictoriousErrorDomain
                                                       code:VAccountUpdateViewControllerBadPasswordErrorCode
                                                   userInfo:userInfoDict];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender
{
    [[self view] endEditing:YES];
    
    if (YES == [self shouldUpdatePassword:self.changedPasswordTextField.text
                             confirmation:self.confirmPasswordTextField.text])
    {
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
            NSString *title = nil;
            NSString *message = nil;
            
            [self localizedErrorStringsForError:error title:&title message:&message];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        };
        
        [[VObjectManager sharedManager] updatePasswordWithCurrentPassword:self.oldPasswordTextField.text
                                                              newPassword:self.changedPasswordTextField.text
                                                             successBlock:success
                                                                failBlock:fail];
    }
}

- (BOOL)localizedErrorStringsForError:(NSError *)error title:(NSString **)title message:(NSString **)message
{
    if ( title == nil || message == nil )
    {
        return NO;
    }
    
    if ( error.code == kVCurrentPasswordIsInvalid )
    {
        *title = NSLocalizedString(@"ResetPasswordErrorIncorrectTitle", @"");
        *message = NSLocalizedString(@"ResetPasswordErrorIncorrectMessage", @"");
    }
    else if ( error.code == kVPasswordResetCodeExpired )
    {
        *title = NSLocalizedString(@"ResetPasswordErrorFailTitle", @"");
        *message = NSLocalizedString(@"ResetPasswordErrorFailMessage", @"");
    }
    else
    {
        *title = NSLocalizedString(@"ResetPasswordErrorFailTitle", @"");
        *message = NSLocalizedString(@"ResetPasswordErrorFailMessage", @"");
    }
    
    return YES;
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.oldPasswordTextField])
    {
        [self.changedPasswordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.changedPasswordTextField])
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else
    {
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
