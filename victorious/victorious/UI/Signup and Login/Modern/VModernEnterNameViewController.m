//
//  VModernEnterNameViewController.m
//  victorious
//
//  Created by Michael Sena on 5/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernEnterNameViewController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"

// Views + Helpers
#import "VInlineValidationTextField.h"
#import "VLoginFlowControllerResponder.h"

static NSString *kPromptKey = @"prompt";
static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VModernEnterNameViewController () <VBackgroundContainer, UITextFieldDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *promptLabel;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *nameField;
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
    
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    self.promptLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString([self.dependencyManager stringForKey:kPromptKey], nil)
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
    self.nameField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    self.nameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter name", nil)
                                                                           attributes:placeholderTextFieldAttributes];
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(next:)];
    self.navigationItem.rightBarButtonItem = nextItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.nameField becomeFirstResponder];
    
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - Target/Action

- (void)next:(id)sender
{
    if ([self shouldSetUsername:self.nameField.text])
    {
        [self.view endEditing:YES];
        
        id<VLoginFlowControllerResponder> loginFlowController = [self targetForAction:@selector(setUsername:)
                                                                           withSender:self];
        if (loginFlowController == nil)
        {
            NSAssert(false, @"We need a login flow responder for updating username.");
        }
        
        [loginFlowController setUsername:[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self next:nil];
    return YES;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - Private Methods

- (BOOL)shouldSetUsername:(NSString *)name
{
    NSString *trimmedString = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length == 0)
    {
        [self.nameField showInvalidText:NSLocalizedString(@"You must enter a name.", nil)
                               animated:YES
                                  shake:YES
                                 forced:YES];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
