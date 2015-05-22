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

@interface VModernLandingViewController ()

@property (nonatomic, strong) UIButton *registerButton;

@end

@implementation VModernLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(toRegsiter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
    [self.view v_addCenterToParentContraintsToSubview:self.registerButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(selectedCancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeHeaderImage"]];
    self.navigationItem.titleView = headerImageView;
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginButton;
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

- (void)toRegsiter
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedRegister)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for registerring.");
    }
    [flowControllerResponder selectedRegister];
}

@end
