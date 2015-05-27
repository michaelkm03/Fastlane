//
//  VModernResetTokenViewController.m
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernResetTokenViewController.h"

// Views + Helpers
#import "VLoginFlowControllerResponder.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VDependencyManager+VBackgroundContainer.h"

@import CoreText;

static NSString *kPromptKey = @"prompt";
static NSString *kKeyboardStyleKey = @"keyboardStyle";

@interface VModernResetTokenViewController () <UITextFieldDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *resendEmailButton;

@end

@implementation VModernResetTokenViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                         bundle:bundleForClass];
    VModernResetTokenViewController *resetTokenViewController = [storyboard instantiateInitialViewController];
    resetTokenViewController.dependencyManager = dependencyManager;
    return resetTokenViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *prompt = [self.dependencyManager stringForKey:kPromptKey] ?: @"";
    NSDictionary *promptAttributes = @{
                                       NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey],
                                       NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                       };
    self.promptLabel.attributedText = [[NSAttributedString alloc] initWithString:prompt
                                                                      attributes:promptAttributes];
    self.enterCodeLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Code", nil)
                                                                         attributes:promptAttributes];

    NSDictionary *textFieldAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]
                                          };
    self.codeTextField.textColor = textFieldAttributes[NSForegroundColorAttributeName];
    self.codeTextField.font = textFieldAttributes[NSFontAttributeName];
    self.codeTextField.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.codeTextField.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    
    NSString *localizedResend = NSLocalizedString(@"Resend Email", nil);
    NSMutableAttributedString *attributedResend = [[NSMutableAttributedString alloc] initWithString:localizedResend
                                                                                         attributes:promptAttributes];
    [attributedResend addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                             value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                             range:NSMakeRange(0, localizedResend.length)];
    [self.resendEmailButton setAttributedTitle:[attributedResend copy]
                                      forState:UIControlStateNormal];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"")
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(resetPasswordWithTextFieldToken)];
    NSDictionary *nextButtonAttributes = @{
                                           NSFontAttributeName:[self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
                                           NSForegroundColorAttributeName:[self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey]
                                           };
    [nextButton setTitleTextAttributes:nextButtonAttributes
                                   forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nextButton;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.codeTextField becomeFirstResponder];
}

#pragma mark - Target/Action

- (IBAction)resendEmail:(id)sender
{
    id<VLoginFlowControllerResponder> flowController = [self targetForAction:@selector(forgotPasswordWithInitialEmail:)
                                                                  withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for forgot password");
    }
    [flowController forgotPasswordWithInitialEmail:nil];
}

#pragma mark - Internal Methods

- (void)resetPasswordWithTextFieldToken
{
    id<VLoginFlowControllerResponder> flowController = [self targetForAction:@selector(setResetToken:)
                                                                  withSender:self];
    if (flowController == nil)
    {
        NSAssert(false, @"We need a flow controller for reset tokens.");
    }
    [flowController setResetToken:self.codeTextField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resetPasswordWithTextFieldToken];
    return YES;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
