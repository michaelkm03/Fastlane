//
//  VModernRegisterViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernRegisterViewController.h"

// Libraries
#import <MBProgressHUD/MBProgressHUD.h>

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"

// Views + Helpers
#import "VInlineValidationTextField.h"
#import "VPasswordValidator.h"
#import "VEmailValidator.h"
#import "VBackgroundContainer.h"

static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VModernRegisterViewController () <UITextFieldDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *promptTextView;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordField;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.emailValidator = [[VEmailValidator alloc] init];
    self.passwordValidator = [[VPasswordValidator alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.emailField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.passwordField];
    
    self.promptTextView.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.promptTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    self.emailField.font = textFieldAttributes[NSFontAttributeName];
    self.emailField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                              attributes:textFieldAttributes]];
    [self.emailField setKeyboardAppearance:[self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey]];
    [self.passwordField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                                 attributes:textFieldAttributes]];
    self.passwordField.font = textFieldAttributes[NSFontAttributeName];
    self.passwordField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.passwordField setKeyboardAppearance:[self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey]];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(signup)];
    NSDictionary *nextButtonAttributes = @{
                                           NSFontAttributeName:[self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
                                           NSForegroundColorAttributeName:[self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey]
                                           };
    [self.nextButton setTitleTextAttributes:nextButtonAttributes
                                   forState:UIControlStateNormal];
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
    
    [self.emailField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
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
    
    [self.passwordValidator setConfirmationObject:nil
                                      withKeyPath:nil];
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
#warning Do signup stuff
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                                  animated:YES];
        hud.labelText = @"signing up....";
        
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
