//
//  VModernEnterNameViewController.m
//  victorious
//
//  Created by Michael Sena on 5/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernEnterNameViewController.h"
#import "victorious-Swift.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VLoginAndRegistration.h"

// Views + Helpers
#import "VLoginFlowControllerDelegate.h"

static NSString * const kUsernameAlreadyTakenErrorMessage = @"username not available";

@interface VModernEnterNameViewController () <VBackgroundContainer, UITextFieldDelegate, VLoginFlowScreen>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet InlineValidationTextField *nameField;
@property (nonatomic, weak) IBOutlet UIView *separator;

@end

@implementation VModernEnterNameViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VModernEnterNameViewController *enterNameViewController = [storyboard instantiateInitialViewController];
    enterNameViewController.dependencyManager = dependencyManager;
    return enterNameViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.separator.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    
    NSString *promptText = [self.dependencyManager stringForKey:VScreenPromptKey] ?: @"";
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    self.promptLabel.attributedText = [[NSAttributedString alloc] initWithString:promptText
                                                                      attributes:promptAttributes];

    NSDictionary *fieldAttributes = @{
                                      NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                      NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                      };
    NSDictionary *placeholderTextFieldAttributes = @{
                                                     NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                                     NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey],
                                                     };
    self.nameField.font = fieldAttributes[NSFontAttributeName];
    self.nameField.textColor = fieldAttributes[NSForegroundColorAttributeName];
    self.nameField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.nameField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:VKeyboardStyleKey];
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter name", nil)
                                                                           attributes:placeholderTextFieldAttributes];
    self.nameField.accessibilityIdentifier = VAutomationIdentifierSignupUsernameField;
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    [self.delegate configureFlowNavigationItemWithScreen:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.nameField becomeFirstResponder];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

#pragma mark - VLoginFlowScreen

- (BOOL)displaysAfterSocialRegistration
{
    NSNumber *value = [self.dependencyManager numberForKey:VDisplayWithSocialRegistration];
    return value.boolValue;
}

@synthesize delegate = _delegate;

- (void)onContinue:(id)sender
{
    if ([self validateUsernameFrom:self.nameField])
    {
        [self.view endEditing:YES];
        
        NSString *username = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self.delegate setUsername:username displayName:username completion:^(BOOL success, NSError *error) {
            if ([error.localizedDescription isEqualToString:kUsernameAlreadyTakenErrorMessage])
            {
                [self.nameField showInvalidText:NSLocalizedString(@"UsernameTaken", @"") animated:YES shake:YES forced:YES];
            }
            else if (!success)
            {
                [self v_showErrorDefaultError];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onContinue:nil];
    return YES;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
