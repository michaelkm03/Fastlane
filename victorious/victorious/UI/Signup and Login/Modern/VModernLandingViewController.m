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

#import <CCHLinkTextView/CCHLinkTextView.h>
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"

@import CoreText;

static NSString * const kSigninOptionsKey = @"signInOptions";
static NSString * const kLogoKey = @"logo";
static NSString * const kStatusBarStyle = @"statusBarStyle";
static NSString * const kTermsOfServiceLinkValue = @"termsOfService";
static NSString * const kPrivacyPolicyLinkValue = @"privacyPolicy";
static NSString * const kEmailKey = @"email";
static NSString * const kFacebookKey = @"facebook";
static NSString * const kTwitterKey = @"twitter";

static CGFloat const kLoginButtonToTextViewSpacing = 8.0f;

@interface VModernLandingViewController () <CCHLinkTextViewDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIButton *twitterButton;
@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet CCHLinkTextView *legalTextView;

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
    
    [self setupSigninOptions];
    
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
    NSString *legalTextBeginnning = NSLocalizedString(@"By signing up you are agreeing to our \n", nil);
    NSString *termsOfServiceLinkText = NSLocalizedString(@"terms of service", nil);
    NSString *andText = NSLocalizedString(@" and ", nil);
    NSString *privacyPolicyLinkText = NSLocalizedString(@"privacy policy.", nil);
    NSDictionary *legalTextAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    NSDictionary *legalTextHighlightAttributes = @{
                                                   NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                                   NSForegroundColorAttributeName: [[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey] colorWithAlphaComponent:0.5f],
                                                   };
    NSMutableAttributedString *attributedLegalText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@%@", legalTextBeginnning, termsOfServiceLinkText, andText, privacyPolicyLinkText]
                                                                                            attributes:legalTextAttributes];
    NSRange rangeOfTOSLink = [attributedLegalText.string rangeOfString:termsOfServiceLinkText];
    NSRange rangeOfPrivacyPolicyLink = [attributedLegalText.string rangeOfString:privacyPolicyLinkText];
    [attributedLegalText addAttribute:CCHLinkAttributeName
                                value:kTermsOfServiceLinkValue
                                range:rangeOfTOSLink];
    [attributedLegalText addAttribute:CCHLinkAttributeName
                                value:kPrivacyPolicyLinkValue
                                range:rangeOfPrivacyPolicyLink];
    [attributedLegalText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                range:rangeOfTOSLink];
    [attributedLegalText addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                                value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                                range:rangeOfPrivacyPolicyLink];
    self.legalTextView.attributedText = attributedLegalText;
    self.legalTextView.textAlignment = NSTextAlignmentCenter;
    self.legalTextView.linkTextAttributes = legalTextAttributes;
    self.legalTextView.linkDelegate = self;
    self.legalTextView.linkTextTouchAttributes = legalTextHighlightAttributes;

    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // Text was scrolled out of frame without this.
    self.legalTextView.contentOffset = CGPointZero;
}

#pragma mark - Target/Action

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

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(showTermsOfService)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for terms of service.");
    }
    
    if ([value isEqualToString:kTermsOfServiceLinkValue])
    {
        [flowControllerResponder showTermsOfService];
    }
    else
    {
        [flowControllerResponder showPrivacyPolicy];
    }
}

#pragma mark - Internal Methods

- (void)setupSigninOptions
{
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    self.emailButton.hidden = YES;
    
    NSArray *options = [self.dependencyManager arrayForKey:kSigninOptionsKey];
    
    UIButton *firstButton = [self buttonForLoginType:[options firstObject]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.legalTextView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:firstButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:-kLoginButtonToTextViewSpacing]];
    
    for (NSUInteger idx = 0; idx < options.count; idx++)
    {
        NSString *currentLoginType = options[idx];
        UIButton *currentBUtton = [self buttonForLoginType:currentLoginType];
        currentBUtton.hidden = NO;
        if (idx > 0)
        {
            NSString *previousLoginType = options[idx - 1];
            UIButton *previousButton = [self buttonForLoginType:previousLoginType];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:previousButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:currentBUtton
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
        }
    }
    UIButton *lastButton = [self buttonForLoginType:[options lastObject]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lastButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (UIButton *)buttonForLoginType:(NSString *)loginType
{
    if ([loginType isEqualToString:kEmailKey])
    {
        return self.emailButton;
    }
    else if ([loginType isEqualToString:kFacebookKey])
    {
        return self.facebookButton;
    }
    else if ([loginType isEqualToString:kTwitterKey])
    {
        return self.twitterButton;
    }
    else
    {
        return nil;
    }
}

@end
