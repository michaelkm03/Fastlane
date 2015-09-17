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
#import "VConstants.h"
#import "VPasswordValidator.h"
#import "VButton.h"
#import "VInlineValidationTextField.h"
#import "VDependencyManager.h"

static const CGFloat kPlaceholderTextWhiteValue = 0.14f;
static const CGFloat kPlaceholderActiveTextWhiteValue = 0.4f;

@interface VChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet VInlineValidationTextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet VInlineValidationTextField *changedPasswordTextField;
@property (weak, nonatomic) IBOutlet VInlineValidationTextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet VButton *saveButton;

@property (strong, nonatomic) VPasswordValidator *passwordValidator;

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
    
    self.saveButton.style = VButtonStylePrimary;
    self.saveButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.saveButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    NSDictionary *placeholderAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:kPlaceholderTextWhiteValue alpha:1.0f] };
    NSDictionary *activePlaceholderAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:kPlaceholderActiveTextWhiteValue alpha:1.0f] };
    
    NSArray *textFields = @[ self.oldPasswordTextField, self.changedPasswordTextField, self.confirmPasswordTextField ];
    for ( VInlineValidationTextField *textField in textFields )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
        
        [textField applyTextFieldStyle:VTextFieldStyleLoginRegistration];
        textField.delegate = self;
    }
    
    NSString *placeholderText = self.oldPasswordTextField.placeholder;
    if ( placeholderText != nil )
    {
        self.oldPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.oldPasswordTextField.placeholder
                                                                                      attributes:activePlaceholderAttributes];
        self.oldPasswordTextField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:self.oldPasswordTextField.placeholder
                                                                                        attributes:placeholderAttributes];
    }
    
    NSString *passwordActivePlaceholder = NSLocalizedString(@"Minimum 8 characters", @"");
    self.confirmPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                      attributes:activePlaceholderAttributes];
    self.confirmPasswordTextField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                        attributes:placeholderAttributes];
    self.changedPasswordTextField.activePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                      attributes:activePlaceholderAttributes];
    self.changedPasswordTextField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:passwordActivePlaceholder
                                                                                        attributes:placeholderAttributes];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
        self.saveButton.enabled = NO;
        [self.saveButton showActivityIndicator];
        
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            self.saveButton.enabled = YES;
            [self.saveButton hideActivityIndicator];
            
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
            self.saveButton.enabled = YES;
            [self.saveButton hideActivityIndicator];
            
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
    
    if (textField == self.oldPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
        if ( ![self.passwordValidator validateString:textField.text andError:&validationError] &&
            validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
        {
            [textField showInvalidText:validationError.localizedDescription animated:NO shake:NO forced:NO];
        }
        else
        {
            [textField hideInvalidText];
        }
    }
    if (textField == self.changedPasswordTextField)
    {
        [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
        if ( ![self.passwordValidator validateString:textField.text andError:&validationError] &&
            validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
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
        if ( ![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError] &&
            validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
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
    if (![self.passwordValidator validateString:self.oldPasswordTextField.text andError:&validationError] &&
        validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
    {
        [self.oldPasswordTextField showInvalidText:validationError.localizedDescription animated:YES shake:YES forced:YES];
        
        shouldSignup = NO;
        if (newResponder == nil)
        {
            [self.oldPasswordTextField becomeFirstResponder];
            newResponder = self.oldPasswordTextField;
        }
    }
    [self.passwordValidator setConfirmationObject:nil withKeyPath:nil];
    if (![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError] &&
        validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
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
    if (![self.passwordValidator validateString:self.changedPasswordTextField.text andError:&validationError] &&
        validationError.code != VErrorCodeInvalidPasswordsNewEqualsCurrent )
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
