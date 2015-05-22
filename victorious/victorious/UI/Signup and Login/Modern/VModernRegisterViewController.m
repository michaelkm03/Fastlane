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

// Views + Helpers
#import "VInlineValidationTextField.h"

static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VModernRegisterViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *promptTextView;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *emailField;
@property (nonatomic, weak) IBOutlet VInlineValidationTextField *passwordField;

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

    NSDictionary *placeholderAttributes = @{
                                            NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                            NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                            };

    [self.emailField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Email", nil)
                                                                              attributes:placeholderAttributes]];
    [self.emailField setKeyboardAppearance:[self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey]];
    [self.passwordField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Password", nil)
                                                                                 attributes:placeholderAttributes]];
    [self.passwordField setKeyboardAppearance:[self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey]];
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

@end
