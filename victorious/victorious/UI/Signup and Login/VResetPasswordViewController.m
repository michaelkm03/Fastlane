//
//  VResetPasswordViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VResetPasswordViewController.h"
#import "VObjectManager+Login.h"
#import "VDependencyManager.h"
#import "UIImage+ImageEffects.h"
#import "VConstants.h"
#import "VPasswordValidator.h"
#import "VButton.h"
#import "VInlineValidationTextField.h"

@interface VResetPasswordViewController ()  <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *confirmPasswordTextField;
@property (nonatomic, weak) IBOutlet VButton *updateButton;
@property (nonatomic, weak) IBOutlet VButton *cancelButton;

@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@end

@implementation VResetPasswordViewController

@synthesize registrationStepDelegate; //< VRegistrationStep

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.passwordTextField.font = [self.dependencyManager fontForKey:@"font.header"];
    self.passwordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.passwordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    self.confirmPasswordTextField.font = [self.dependencyManager fontForKey:@"font.header"];
    self.confirmPasswordTextField.textColor = [UIColor colorWithWhite:0.14 alpha:1.0];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.confirmPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0]}];
    
    self.cancelButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.cancelButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    self.cancelButton.style = VButtonStyleSecondary;
    
    self.updateButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.updateButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    self.updateButton.style = VButtonStylePrimary;
    
    self.passwordTextField.delegate  =   self;
    self.confirmPasswordTextField.delegate  =   self;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.passwordValidator = [[VPasswordValidator alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)update:(id)sender
{
    [[self view] endEditing:YES];
    
    NSString *newPassword = self.passwordTextField.text;
    
    NSError *outError = nil;
    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                      withKeyPath:NSStringFromSelector(@selector(text))];
    if ([self.passwordValidator validateString:newPassword
                                      andError:&outError])
    {
        [[VObjectManager sharedManager] resetPasswordWithUserToken:self.userToken
                                                       deviceToken:self.deviceToken
                                                       newPassword:newPassword
                                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             // This will always be NO for success because resetting password does not complete the login/registraiton process
             [self.registrationStepDelegate didFinishRegistrationStepWithSuccess:NO];
    
         }
                                                         failBlock:^(NSOperation *operation, NSError *error)
         {
             NSString *title = NSLocalizedString( @"Error Resetting Password", @"" );
             NSString *message = NSLocalizedString( @"Please check your network connection or try agian later.", @"" );
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString( @"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
             [self presentViewController:alertController animated:YES completion:nil];
         }];
    }
    else
    {
        [self.passwordValidator showAlertInViewController:self withError:outError];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField)
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTextField)
    {
        [self.confirmPasswordTextField resignFirstResponder];
    }
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

@end
