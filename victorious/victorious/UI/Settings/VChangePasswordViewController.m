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
#import "VPasswordValidator.h"

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

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender
{
    [[self view] endEditing:YES];
    
    if (YES == [VPasswordValidator validatePassword:self.changedPasswordTextField.text
                             confirmation:self.confirmPasswordTextField.text])
    {
        [[VObjectManager sharedManager] loginToVictoriousWithEmail:[[VObjectManager sharedManager] mainUser].email
                                                          password:self.oldPasswordTextField.text
                                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 [self.navigationController popViewControllerAnimated:YES];
             };
             
             VFailBlock fail = ^(NSOperation *operation, NSError *error)
             {
                 UIAlertView    *alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AccountUpdateFail", @"")
                                                                        message:error.localizedDescription
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
                                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             UIAlertView    *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InvalidCredentials", @"")
                                                                message:NSLocalizedString(@"IncorrectOldPassword", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"OKButton", @""), nil];
             [alert show];
         }];
    }
    else
    {
        [[self view] endEditing:YES];
    }
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
