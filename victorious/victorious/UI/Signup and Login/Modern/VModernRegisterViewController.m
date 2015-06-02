//
//  VModernRegisterViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernRegisterViewController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VConstants.h"

// Views + Helpers
#import "VInlineValidationTextField.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VBackgroundContainer.h"
#import "VLoginFlowControllerResponder.h"

static NSString * const kPromptKey = @"prompt";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VModernRegisterViewController () <UITextFieldDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *promptTextView;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordField;
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
    self.promptTextView.text = NSLocalizedString(prompt, nil);
    self.promptTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.promptTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.promptTextView.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    NSDictionary *placeholderTextFieldAttributes = @{
                                                     NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey],
                                                     };
    self.emailField.font = textFieldAttributes[NSFontAttributeName];
    self.emailField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                            attributes:placeholderTextFieldAttributes];
    self.emailField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];

    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                               attributes:placeholderTextFieldAttributes];
    self.passwordField.font = textFieldAttributes[NSFontAttributeName];
    self.passwordField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.passwordField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(signup)];
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.emailField clearValidation];
    [self.passwordField clearValidation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.emailField.text = nil;
    self.passwordField.text = nil;
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
        [self signup];
    }
    
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

- (BOOL)shouldSignUp
{
    NSError *validationError;
    BOOL shouldSignup = YES;
    
    if (![self.emailValidator validateString:self.emailField.text andError:&validationError])
    {
        [self.emailField showInvalidText:validationError.localizedDescription
                                animated:YES
                                   shake:YES
                                  forced:YES];
        
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
                                     forced:YES];
        
        NSDictionary *params = @{ VTrackingKeyErrorMessage : validationError.localizedDescription ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailValidationDidFail parameters:params];
        
        shouldSignup = NO;
        [self.passwordField becomeFirstResponder];
    }
    return shouldSignup;
}

- (void)signup
{
    if ([self shouldSignUp])
    {
        id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(registerWithEmail:password:completion:)
                                                                               withSender:self];
        if (flowControllerResponder == nil)
        {
            NSAssert(false, @"We need a flow controller responder in the responder chain for registering.");
        }
        
        [flowControllerResponder registerWithEmail:self.emailField.text
                                          password:self.passwordField.text
                                        completion:^(BOOL success, NSError *error)
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
    NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventSignupWithEmailDidFail parameters:params];
    
    NSString *message = NSLocalizedString(@"GenericFailMessage", @"");
    
    if ( error.code == kVAccountAlreadyExistsError)
    {
        message = NSLocalizedString(@"User already exists", @"");
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignupFail", @"")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end