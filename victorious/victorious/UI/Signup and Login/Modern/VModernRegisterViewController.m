//
//  VModernRegisterViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernRegisterViewController.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VConstants.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VBackgroundContainer.h"
#import "VLoginFlowControllerDelegate.h"
#import "UIColor+VBrightness.h"
#import "victorious-Swift.h"

static NSString * const kPromptKey = @"prompt";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernRegisterViewController () <UITextFieldDelegate, VBackgroundContainer, VLoginFlowScreen>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *promptTextView;
@property (nonatomic, weak) IBOutlet InlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet InlineValidationTextField *passwordField;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *separators;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@property (nonatomic, strong) VPasswordValidator *passwordValidator;
@property (nonatomic, strong) VEmailValidator *emailValidator;

@end

@implementation VModernRegisterViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForSelf = [NSBundle bundleForClass:self];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForSelf];
    VModernRegisterViewController *registerViewController = [storyBoard instantiateInitialViewController];
    registerViewController.dependencyManager = dependencyManager;
    return registerViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIView *separator in self.separators)
    {
        separator.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    }

    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.emailField];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.passwordField];
    
    NSString *prompt = [self.dependencyManager stringForKey:kPromptKey];
    self.promptTextView.text = prompt;
    self.promptTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.promptTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.promptTextView.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [UIFont systemFontOfSize:17],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    NSDictionary *placeholderTextFieldAttributes = @{
                                                     NSFontAttributeName: [UIFont systemFontOfSize:17],
                                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey],
                                                     };
    UIColor *normalColor = textFieldAttributes[NSForegroundColorAttributeName];
    UIColor *highlightedColor = ([normalColor v_colorLuminance] == VColorLuminanceBright) ? [normalColor v_colorDarkenedBy:0.3f] : [normalColor v_colorDarkenedBy:0.3f];
    NSDictionary *activePlaceholderAttributes = @{
                                                  NSFontAttributeName: placeholderTextFieldAttributes[NSFontAttributeName],
                                                  NSForegroundColorAttributeName: highlightedColor,
                                                  };
    
    self.emailField.font = textFieldAttributes[NSFontAttributeName];
    self.emailField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.emailField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                            attributes:placeholderTextFieldAttributes];
    self.emailField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    self.emailField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder
                                                                        attributes:activePlaceholderAttributes];
    self.emailField.accessibilityIdentifier = VAutomationIdentifierSignupEmailField;

    self.passwordField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                             attributes:placeholderTextFieldAttributes];
    self.passwordField.accessibilityIdentifier = VAutomationIdentifierSignupPasswordField;
    
    self.passwordField.font = textFieldAttributes[NSFontAttributeName];
    self.passwordField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.passwordField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    self.passwordField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"")
                                                                           attributes:activePlaceholderAttributes];
    
    [self.delegate configureFlowNavigationItemWithScreen:self];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Text was scrolled out of frame without this.
    self.promptTextView.contentOffset = CGPointZero;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
    [self.emailField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];

    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
}

#pragma mark - VLoginFlowScreen

@synthesize delegate = _delegate;

- (void)onContinue:(id)sender
{
    if ([self shouldSignUpForced:YES])
    {
        [self.view endEditing:YES];
        [self.delegate registerWithEmail:self.emailField.text
                                password:self.passwordField.text
                              completion:^(BOOL success, BOOL alreadyRegistered, NSError *error)
         {
             if (!success)
             {
                 [self failedWithError:error];
             }
         }];
    }
}

#pragma mark - Notifications

- (void)textFieldDidChange:(NSNotification *)notification
{
    InlineValidationTextField *textField = notification.object;
    [self validateWithTextField:textField];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(InlineValidationTextField *)textField
{
    if ( textField.text.length > 0 )
    {
        [self validateWithTextField:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(InlineValidationTextField *)textField
{
    if (textField == self.emailField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField)
    {
        [self onContinue:nil];
    }
    
    return [self shouldSignUpForced:NO];
}

#pragma mark - Private Methods

- (void)validateWithTextField:(InlineValidationTextField *)textField
{
    NSError *validationError;
    
    if (textField == self.emailField)
    {
        BOOL validEmail = [self.emailValidator validateString:textField.text
                                                     andError:&validationError];
        if (!validEmail)
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
    if (textField == self.passwordField)
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
}

- (BOOL)shouldSignUpForced:(BOOL)forced
{
    NSError *validationError;
    BOOL shouldSignup = YES;
    
    if (![self.emailValidator validateString:self.emailField.text andError:&validationError])
    {
        [self.emailField showInvalidText:validationError.localizedDescription
                                animated:YES
                                   shake:YES
                                  forced:forced];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.emailField becomeFirstResponder];
    }

    if (![self.passwordValidator validateString:self.passwordField.text andError:&validationError] && shouldSignup)
    {
        [self.passwordField showInvalidText:validationError.localizedDescription
                                   animated:YES
                                      shake:YES
                                     forced:forced];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.passwordField becomeFirstResponder];
    }
    return shouldSignup;
}

- (void)signup
{
    [self.view endEditing:YES];
    if ([self shouldSignUpForced:YES])
    {
        [self.delegate registerWithEmail:self.emailField.text
                                          password:self.passwordField.text
                                        completion:^(BOOL success, BOOL alreadyRegistered, NSError *error)
         {
             if (!success)
             {
                 [self failedWithError:error];
             }
         }];
    }
}

- (void)failedWithError:(NSError *)error
{
    if ( [error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled )
    {
        return;
    }
    
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidFail parameters:params];
    
    NSString *message = NSLocalizedString(@"GenericFailMessage", @"");
    
    if ( error.code == kVAccountAlreadyExistsError)
    {
        message = NSLocalizedString(@"User already exists", @"");
    }
    else if ( error.code == kVPasswordInvalidForExistingUser )
    {
        message = NSLocalizedString(@"User already exists but the password is incorrect", @"");
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [self.delegate loginErrorAlertAcknowledged];
                                                      }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
