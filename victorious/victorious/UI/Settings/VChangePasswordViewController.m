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
#import "VButton.h"
#import "VSettingManager.h"
#import "VInlineValidationTextField.h"
#import "VDependencyManager.h"

@interface VChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet VInlineValidationTextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet VInlineValidationTextField *changedPasswordTextField;
@property (weak, nonatomic) IBOutlet VInlineValidationTextField *confirmPasswordTextField;
@property (strong, nonatomic) VPasswordValidator *passwordValidator;
@property (nonatomic, weak) IBOutlet VButton *signupButton;

@end

@implementation VChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.oldPasswordTextField.delegate = nil;
    self.changedPasswordTextField.delegate = nil;
    self.confirmPasswordTextField.delegate = nil;

    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    self.view.layer.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0].CGColor;
    
    [self updateStyle];
    
    [self.oldPasswordTextField becomeFirstResponder];
}

- (void)dealloc
{
    NSArray *textFields = @[ self.oldPasswordTextField, self.changedPasswordTextField, self.confirmPasswordTextField ];
    for ( VInlineValidationTextField *textField in textFields )
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
    }
}

- (void)updateStyle
{
    if ( !self.isViewLoaded )
    {
        return;
    }
    
    self.signupButton.style = VButtonStylePrimary;
    self.signupButton.primaryColor = [self.dependencyManager colorForKey:@"color.link"];
    self.signupButton.titleLabel.font = [self.dependencyManager fontForKey:@"font.header"];
    
    NSDictionary *placeholderAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.14 alpha:1.0] };
    UIColor *activePlaceholderColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
    NSDictionary *activePlaceholderAttributes = @{ NSForegroundColorAttributeName : activePlaceholderColor };
    
    NSArray *textFields = @[ self.oldPasswordTextField, self.changedPasswordTextField, self.confirmPasswordTextField ];
    for ( VInlineValidationTextField *textField in textFields )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        
        [textField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
        textField.delegate = self;
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:placeholderAttributes];
    }
    
    self.oldPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.oldPasswordTextField.placeholder
                                                                                  attributes:activePlaceholderAttributes];
    
    NSString *passwordActivePlaceholder = NSLocalizedString(@"Minimum 8 characters", @"");
    self.confirmPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                      attributes:activePlaceholderAttributes];
    self.changedPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                      attributes:activePlaceholderAttributes];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self updateStyle];
}

#pragma mark - Actions

- (IBAction)saveChanges:(id)sender
{
    [[self view] endEditing:YES];
    
    if ( [self shouldSignUp] )
    {
        [self performPasswordUpdate];
    }
}

- (void)performPasswordUpdate
{
    // Point the validator at the field to confirm the password
    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField withKeyPath:@"text"];
    
    NSError *validationError;
    self.passwordValidator.currentPassword = self.oldPasswordTextField.text;
    if ([self.passwordValidator validateString:self.changedPasswordTextField.text
                                      andError:&validationError])
    {
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
            [self.passwordValidator showAlertInViewController:self withError:error];
        };
        
        [[VObjectManager sharedManager] updatePasswordWithCurrentPassword:self.oldPasswordTextField.text
                                                              newPassword:self.changedPasswordTextField.text
                                                             successBlock:success
                                                                failBlock:fail];
    }
    else
    {
        [self.passwordValidator showAlertInViewController:self withError:validationError];
    }
}

- (void)validateWithTextField:(VInlineValidationTextField *)textField
{
    NSError *validationError;
    
    if (textField == self.changedPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
        if ( ![self.passwordValidator validateString:textField.text andError:&validationError] )
        {
            [textField showInvalidText:validationError.localizedDescription animated:NO shake:NO forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
    if (textField == self.confirmPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField withKeyPath:NSStringFromSelector(@selector(text))];
        if ( ![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError] )
        {
            [textField showInvalidText:validationError.localizedDescription animated:NO shake:NO forced:NO];
        }
        else
        {
            [textField hideInvalidText];
            [self.changedPasswordTextField hideInvalidText];
        }
    }
}

#pragma mark - Validation

- (BOOL)shouldSignUp
{
    NSError *validationError;
    BOOL shouldSignup = YES;
    id newResponder = nil;
    
    [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    if (![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError])
    {
        [self.changedPasswordTextField showInvalidText:validationError.localizedDescription animated:YES shake:YES forced:YES];
        
        shouldSignup = NO;
        if (newResponder == nil)
        {
            [self.changedPasswordTextField becomeFirstResponder];
            newResponder = self.changedPasswordTextField;
        }
    }
    
    [self.passwordValidator setConfirmationObject:self.confirmPasswordTextField withKeyPath:NSStringFromSelector(@selector(text))];
    if (![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError])
    {
        [self.confirmPasswordTextField showInvalidText:validationError.localizedDescription animated:YES shake:YES forced:YES];
        
        shouldSignup = NO;
        if (newResponder == nil)
        {
            [self.confirmPasswordTextField becomeFirstResponder];
        }
    }
    
    return shouldSignup;
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    VInlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
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
