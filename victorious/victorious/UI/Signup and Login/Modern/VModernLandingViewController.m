//
//  VModernLandingViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLandingViewController.h"
#import "VLoginFlowControllerResponder.h"
#import "UIView+AutoLayout.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"

static NSString *kLogoKey = @"logo";
static NSString *kStatusBarStyle = @"statusBarStyle";

@interface VModernLandingViewController () <VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *legalTextView;

@end

@implementation VModernLandingViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VModernLandingViewController *landingViewContorller = [[UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                                     bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
    landingViewContorller.dependencyManager = dependencyManager;
    return landingViewContorller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(selectedCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIImage *headerImage = [self.dependencyManager imageForKey:kLogoKey];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:headerImage];
    self.navigationItem.titleView = headerImageView;
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(login)];
    [loginButton setTitleTextAttributes:@{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey],
                                          NSForegroundColorAttributeName:[self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey]}
                               forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = loginButton;

    self.legalTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.legalTextView.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Text was scrolled out of frame without this.
    self.legalTextView.contentOffset = CGPointZero;
}

#pragma mark - Target/Action

- (void)selectedCancel
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(cancelLoginAndRegistration)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for cancelling.");
    }
    [flowControllerResponder cancelLoginAndRegistration];
}

- (void)login
{
    id <VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedLogin)
                                                                            withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for logging in.");
    }
    [flowControllerResponder selectedLogin];
}

- (IBAction)toRegsiter:(id)sender
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedRegister)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for registerring.");
    }
    [flowControllerResponder selectedRegister];
}

- (IBAction)loginWithTwitter:(id)sender
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(loginWithTwitter)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for registerring.");
    }
    [flowControllerResponder loginWithTwitter];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end
