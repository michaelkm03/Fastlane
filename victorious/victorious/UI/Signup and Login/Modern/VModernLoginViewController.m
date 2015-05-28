//
//  VModernLoginViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLoginViewController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VConstants.h"

// Views + Helpers
#import "VInlineValidationTextField.h"
#import "VEmailValidator.h"
#import "VPasswordValidator.h"
#import "VLoginFlowControllerResponder.h"

@import CoreText;

static NSString * const kPromptKey = @"prompt";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernLoginViewController () <UITextFieldDelegate, UITextViewDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VEmailValidator *emailValidator;
@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextView *forgotpasswordTextView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *separators;

@property (nonatomic, strong) UIBarButtonItem *nextButton;

@end

@implementation VModernLoginViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VModernLoginViewController *loginViewController = [storyboard instantiateInitialViewController];
    loginViewController.dependencyManager = dependencyManager;
    return loginViewController;
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
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    self.promptLabel.attributedText = [[NSAttributedString alloc] initWithString:prompt
                                                                      attributes:promptAttributes];
    
    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                          };
    NSDictionary *placeholderTextFieldAttributes = @{
                                                     NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey],
                                                     };
    self.emailField.textColor = textFieldAttributes[NSForegroundColorAttributeName];
    self.emailField.font = textFieldAttributes[NSFontAttributeName];
    self.emailField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                            attributes:placeholderTextFieldAttributes];
    self.emailField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    self.passwordField.textColor = textFieldAttributes[NSForegroundColorAttributeName];
    self.passwordField.font = textFieldAttributes[NSFontAttributeName];
    self.passwordField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                               attributes:placeholderTextFieldAttributes];
    self.passwordField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    NSString *forgotPasswordText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Forgot your password?", nil), NSLocalizedString(@"Click Here", nil)];
    NSDictionary *forgotPasswordAttributes = @{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey],
                                               NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]};
    NSMutableAttributedString *mutableForgotPasswordText = [[NSMutableAttributedString alloc] initWithString:forgotPasswordText
                                                                                                  attributes:forgotPasswordAttributes];
    NSRange clickHereRange = [forgotPasswordText rangeOfString:NSLocalizedString(@"Click Here", nil)];
    [mutableForgotPasswordText addAttribute:NSLinkAttributeName
                                      value:@"forgotPasswordLink"
                                      range:clickHereRange];
    [mutableForgotPasswordText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                      range:clickHereRange];
    [self.forgotpasswordTextView setAttributedText:[mutableForgotPasswordText copy]];
    self.forgotpasswordTextView.textAlignment = NSTextAlignmentCenter;
    self.forgotpasswordTextView.linkTextAttributes = forgotPasswordAttributes;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(login:)];
    NSDictionary *nextButtonAttributes = @{
                                           NSFontAttributeName:[self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
                                           NSForegroundColorAttributeName:[self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey]
                                           };
    [self.nextButton setTitleTextAttributes:nextButtonAttributes
                                   forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = self.nextButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.emailField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.emailField.text = nil;
    self.passwordField.text = nil;
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
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

- (BOOL)textFieldShouldReturn:(VInlineValidationTextField *)textField
{
    if (textField == self.emailField)
    {
        //TODO: TRACKING User pressed enter on email
        [self.passwordField becomeFirstResponder];
        
    }
    else if (textField == self.passwordField)
    {
        //TODO: TRACKING User pressed enter on password
        [self login:textField];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    id<VLoginFlowControllerResponder> loginFlowController = [self targetForAction:@selector(forgotPasswordWithInitialEmail:)
                                                                       withSender:self];
    if (loginFlowController == nil)
    {
        NSAssert(false, @"We need a responder for forgotPassword!");
    }
    
    [loginFlowController forgotPasswordWithInitialEmail:self.emailField.text];
    
    return YES;
}

#pragma mark - Private Methods

- (void)validateWithTextField:(VInlineValidationTextField *)textField
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

#pragma mark - Validation

- (void)login:(id)sender
{
    if ([self shouldLogin])
    {
        id <VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(loginWithEmail:password:completion:)
                                                                                withSender:self];
        if (flowControllerResponder == nil)
        {
            NSAssert(false, @"We need a flow controller in the responder chain for logging in.");
        }
        [flowControllerResponder loginWithEmail:self.emailField.text
                                       password:self.passwordField.text
                                     completion:^(BOOL success, NSError *error)
         {
             if (success)
             {
                 [self.view endEditing:YES];
             }
             else
             {
                 if (error.code != kVUserBannedError)
                 {
                     NSString *message = NSLocalizedString(@"GenericFailMessage", @"");
                     
                     if ( error.code == kVUserOrPasswordInvalidError )
                     {
                         message = NSLocalizedString(@"Invalid email address or password", @"");
                     }
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                                     message:message
                                                                    delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
             }
         }];
    }
}

- (BOOL)shouldLogin
{
    NSError *validationError;
    BOOL shouldLogin = YES;
    id newResponder = nil;
    
    if (![self.emailValidator validateString:self.emailField.text andError:&validationError])
    {
        [self.emailField showInvalidText:validationError.localizedDescription
                                animated:YES
                                   shake:YES
                                  forced:YES];
        shouldLogin = NO;
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailValidationDidFail parameters:params];
        
        if (newResponder == nil)
        {
            [self.emailField becomeFirstResponder];
            newResponder = self.emailField;
        }
    }
    
    if ( ![self.passwordValidator validateString:self.passwordField.text andError:&validationError])
    {
        
        [self.passwordField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:YES];
        shouldLogin = NO;
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailValidationDidFail parameters:params];
        
        if (newResponder == nil)
        {
            [self.passwordField becomeFirstResponder];
        }
    }
    
    return shouldLogin;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
