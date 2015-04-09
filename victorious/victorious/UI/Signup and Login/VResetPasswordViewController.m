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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.confirmPasswordTextField];
    
    self.passwordTextField.delegate = nil;
    self.confirmPasswordTextField.delegate = nil;
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.confirmPasswordTextField];
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
             [[VTrackingManager sharedInstance] trackEvent:VTrackingEventResetPasswordDidSucceed];
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
    UIAlertController *confirmCancel = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ResetPasswordConfirmCancelTitle", @"" ) message:NSLocalizedString(@"ResetPasswordConfirmCancelMessage", @"" ) preferredStyle:UIAlertControllerStyleActionSheet];
    [confirmCancel addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ResetPasswordYesCancelButton", @"" ) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    [confirmCancel addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ResetPasswordNoContinueButton", @"" ) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:confirmCancel animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(VInlineValidationTextField *)textField
{
    if ( textField.text.length > 0 )
    {
        [self validateWithTextField:textField];
    }
    return YES;
}

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

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    VInlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
}

#pragma mark - Private

- (BOOL)shouldResetPassword
{
    BOOL shouldReset = YES;
    NSError *validationError;
    UIResponder *newResponder = nil;
    
    [self.passwordValidator setConfirmationObject:nil
                                      withKeyPath:nil];
    if (![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError])
    {
        [self.passwordTextField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldReset = NO;
        if (newResponder == nil)
        {
            [self.passwordTextField becomeFirstResponder];
            newResponder = self.passwordTextField;
        }
    }
    
    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                      withKeyPath:NSStringFromSelector(@selector(text))];
    if (![self.passwordValidator validateString:self.passwordTextField.text andError:&validationError])
    {
        [self.confirmPasswordTextField showInvalidText:validationError.localizedDescription
                                              animated:YES
                                                 shake:YES
                                                forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldReset = NO;
        if (newResponder == nil)
        {
            [self.confirmPasswordTextField becomeFirstResponder];
        }
    }
    
    return shouldReset;
}

- (void)validateWithTextField:(VInlineValidationTextField *)textField
{
    NSError *validationError;
    
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
    if (textField == self.confirmPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField
                                          withKeyPath:NSStringFromSelector(@selector(text))];
        BOOL validConfimration = [self.passwordValidator validateString:self.passwordTextField.text
                                                               andError:&validationError];
        if (!validConfimration)
        {
            [textField showInvalidText:validationError.localizedDescription
                              animated:NO
                                 shake:NO
                                forced:NO];
        }
        else
        {
            [textField hideInvalidText];
            [self.passwordTextField hideInvalidText];
        }
    }}

@end
