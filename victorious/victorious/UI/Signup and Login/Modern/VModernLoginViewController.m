//
//  VModernLoginViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLoginViewController.h"
#import <CCHLinkTextView/CCHLinkTextView.h>
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VConstants.h"
#import "VEmailValidator.h"
#import "VPasswordValidator.h"
#import "VLoginFlowControllerDelegate.h"
#import "UIColor+VBrightness.h"
#import "victorious-Swift.h"

@import CoreText;

static NSString * const kPromptKey = @"prompt";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernLoginViewController () <UITextFieldDelegate, VBackgroundContainer, CCHLinkTextViewDelegate, VLoginFlowScreen>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) VEmailValidator *emailValidator;
@property (nonatomic, strong) VPasswordValidator *passwordValidator;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet InlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet InlineValidationTextField *passwordField;
@property (nonatomic, weak) IBOutlet CCHLinkTextView *forgotpasswordTextView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *separators;

@property (nonatomic, strong) UIBarButtonItem *nextButton;

@end

@implementation VModernLoginViewController

@synthesize delegate = _delegate;

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
    
    NSString *prompt = [self.dependencyManager stringForKey:kPromptKey] ?: @"";
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    self.promptLabel.attributedText = [[NSAttributedString alloc] initWithString:prompt
                                                                      attributes:promptAttributes];
    
    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [UIFont systemFontOfSize:17],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                          };
    NSDictionary *placeholderTextFieldAttributes = @{
                                                     NSFontAttributeName: [UIFont systemFontOfSize:17],
                                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey],
                                                     };
    UIColor *normalColor = textFieldAttributes[NSForegroundColorAttributeName];
    UIColor *highlightedColor = ([normalColor v_colorLuminance] == VColorLuminanceBright) ? [normalColor v_colorDarkenedBy:0.3f] : [normalColor v_colorDarkenedBy:0.3f];
    NSDictionary *highlightedPlaceholderAttributes = @{
                                                       NSFontAttributeName:textFieldAttributes[NSFontAttributeName],
                                                       NSForegroundColorAttributeName:highlightedColor,
                                                       };
    self.emailField.textColor = normalColor;
    self.emailField.font = textFieldAttributes[NSFontAttributeName];
    self.emailField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.emailField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                            attributes:placeholderTextFieldAttributes];
    self.emailField.activePlaceholder = [[NSAttributedString alloc] initWithString:self.emailField.placeholder
                                                                        attributes:highlightedPlaceholderAttributes];
    self.emailField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    self.passwordField.textColor = textFieldAttributes[NSForegroundColorAttributeName];
    self.passwordField.font = textFieldAttributes[NSFontAttributeName];
    self.passwordField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.passwordField.inactivePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                               attributes:placeholderTextFieldAttributes];
    self.passwordField.activePlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Minimum 8 characters", @"")
                                                                           attributes:highlightedPlaceholderAttributes];
    self.passwordField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    NSString *forgotPasswordText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Forgot your password?", nil), NSLocalizedString(@"Tap Here", nil)];
    NSDictionary *forgotPasswordAttributes = @{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                               NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]};
    NSDictionary *forgotHighlightedAttributes = @{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                                  NSForegroundColorAttributeName: [[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey] colorWithAlphaComponent:0.5f]};
    NSMutableAttributedString *mutableForgotPasswordText = [[NSMutableAttributedString alloc] initWithString:forgotPasswordText
                                                                                                  attributes:forgotPasswordAttributes];
    NSRange clickHereRange = [forgotPasswordText rangeOfString:NSLocalizedString(@"Tap Here", nil)];
    [mutableForgotPasswordText addAttribute:CCHLinkAttributeName
                                      value:@"forgotPasswordLink"
                                      range:clickHereRange];
    [mutableForgotPasswordText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                      range:clickHereRange];
    [self.forgotpasswordTextView setAttributedText:[mutableForgotPasswordText copy]];
    self.forgotpasswordTextView.textAlignment = NSTextAlignmentCenter;
    self.forgotpasswordTextView.linkTextAttributes = forgotPasswordAttributes;
    self.forgotpasswordTextView.linkTextTouchAttributes = forgotHighlightedAttributes;
    self.forgotpasswordTextView.linkDelegate = self;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(login:)];
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    self.emailField.accessibilityIdentifier = VAutomationIdentifierLoginUsernameField;
    self.passwordField.accessibilityIdentifier = VAutomationIdentifierLoginPasswordField;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
    [self.emailField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
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
        //TODO: TRACKING User pressed enter on email
        [self.passwordField becomeFirstResponder];
        
    }
    else if (textField == self.passwordField)
    {
        //TODO: TRACKING User pressed enter on password
        [self login:textField];
    }
    
    return [self shouldLoginForced:NO];
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

#pragma mark - Validation

- (void)login:(id)sender
{
    if ([self shouldLoginForced:YES])
    {
        id <VLoginFlowControllerDelegate> flowControllerResponder = [self targetForAction:@selector(loginWithEmail:password:completion:)
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
                     
                     [self showAlertErrorWithTitle:NSLocalizedString(@"LoginFail", @"") message:message];
                 }
             }
         }];
    }
}

- (void)showAlertErrorWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [self.delegate loginErrorAlertAcknowledged];
                                                      }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)shouldLoginForced:(BOOL)forced
{
    NSError *validationError;
    BOOL shouldLogin = YES;
    id newResponder = nil;
    
    if (![self.emailValidator validateString:self.emailField.text andError:&validationError])
    {
        [self.emailField showInvalidText:validationError.localizedDescription
                                animated:YES
                                   shake:YES
                                  forced:forced];
        shouldLogin = NO;
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventLoginWithEmailValidationDidFail parameters:params];
        
        if (newResponder == nil)
        {
            [self.emailField becomeFirstResponder];
            newResponder = self.emailField;
        }
    }
    
    if ( ![self.passwordValidator validateString:self.passwordField.text andError:&validationError] && shouldLogin)
    {
        
        [self.passwordField showInvalidText:validationError.localizedDescription
                                       animated:YES
                                          shake:YES
                                         forced:forced];
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

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self.delegate forgotPasswordWithInitialEmail:self.emailField.text];
}

@end
