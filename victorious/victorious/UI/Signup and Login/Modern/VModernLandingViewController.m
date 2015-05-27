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

@import CoreText;

static NSString *kLogoKey = @"logo";
static NSString *kStatusBarStyle = @"statusBarStyle";

@interface VModernLandingViewController () <UITextViewDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UITextView *legalTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceFacebookToContainer;

@end

@implementation VModernLandingViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VModernLandingViewController *landingViewContorller = [[UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                                     bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
    landingViewContorller.dependencyManager = dependencyManager;
    return landingViewContorller;
}

#pragma mark - View Lifecycle

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

    // Legal Text
    NSString *legalTextBeginnning = NSLocalizedString(@"By signing up you are agreeing to our ", nil);
    NSString *termsOfServiceLinkText = NSLocalizedString(@"terms of service and privacy policy.", nil);
    NSDictionary *legalTextAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    NSMutableAttributedString *attributedLegalText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", legalTextBeginnning, termsOfServiceLinkText]
                                                                                            attributes:legalTextAttributes];
    NSRange rangeOfLink = [attributedLegalText.string rangeOfString:termsOfServiceLinkText];
    [attributedLegalText addAttribute:NSLinkAttributeName
                                value:@"tos"
                                range:rangeOfLink];
    [attributedLegalText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                range:rangeOfLink];
    self.legalTextView.attributedText = attributedLegalText;
    self.legalTextView.textAlignment = NSTextAlignmentCenter;
    self.legalTextView.linkTextAttributes = legalTextAttributes;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Text was scrolled out of frame without this.
    self.legalTextView.contentOffset = CGPointZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.bottomSpaceFacebookToContainer.constant = 0.0f;
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
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedTwitterAuthorization)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for registerring.");
    }
    [flowControllerResponder selectedTwitterAuthorization];
}

- (IBAction)loginWithFacebook:(id)sender
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedFacebookAuthorization)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in teh respodner chain for facebook.");
    }
    [flowControllerResponder selectedFacebookAuthorization];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(showTermsOfService)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in teh respodner chain for terms of service.");
    }
    [flowControllerResponder showTermsOfService];
    return YES;
}

@end
