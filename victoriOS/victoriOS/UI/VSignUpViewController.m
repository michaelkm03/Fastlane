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

@interface      VSignUpViewController   ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIView *accessoryView;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (BOOL)shouldSignUpWithUsername:(NSString *)username emailAddress:(NSString *)emailAddress password:(NSString *)password
{
    static  NSString *emailRegEx =
        @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
        @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

    BOOL    isValid     =   YES;
    
    isValid &=  (username && (username.length >= 8));
    isValid &= (password && (password.length >= 8));
    
    NSPredicate*    emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    isValid &= (emailAddress && (0 != emailAddress.length) && [emailTest evaluateWithObject:emailAddress]);
    
    if (NO == isValid)
    {
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Invalid Entry" message:@"You must enter a valid email, username and password." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    return isValid;
}

- (void)didSignUp
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didFailToSignUp
{
    
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Account creation failed." message:@"Please try again." delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField notifications

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = self.accessoryView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.inputAccessoryView = nil;
}

#pragma mark -

- (IBAction)signup:(id)sender
{
    if (YES == [self shouldSignUpWithUsername:self.usernameTextField.text
                                 emailAddress:self.emailTextField.text
                                     password:self.passwordTextField.text])
    {
        SuccessBlock success = ^(NSArray* objects)
        {
            if (![[objects firstObject] isKindOfClass:[VUser class]])
            {
                VLog(@"Invalid user object returned in api/account/create");
                [self didFailToSignUp];
                return;
            }
            
            [self didSignUp];
        };

        FailBlock fail = ^(NSError* error)
        {
            [self didFailToSignUp];
        };
        [[[VObjectManager sharedManager] createVictoriousWithEmail:self.emailTextField.text
                                                          password:self.passwordTextField.text
                                                          username:self.usernameTextField.text
                                                      successBlock:success
                                                         failBlock:fail] start];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
