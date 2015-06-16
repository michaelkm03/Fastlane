//
//  VModernLandingViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLandingViewController.h"

// Libraries
#import <CCHLinkTextView/CCHLinkTextView.h>
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

// Views + Helpers
#import "VLoginFlowControllerResponder.h"
#import "UIView+AutoLayout.h"

// ViewControllers
#import "VPromptCarouselViewController.h"

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
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", @"")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(login)];
    self.navigationItem.rightBarButtonItem = loginButton;

    // Legal Text
    NSString *fullLegalText = NSLocalizedString(@"By signing up you are agreeing to our \nterms of service and privacy policy.", nil);
    NSString *termsOfServiceLinkText = NSLocalizedString(@"terms of service", nil);
    NSString *privacyPolicyLinkText = NSLocalizedString(@"privacy policy.", nil);
    NSDictionary *legalTextAttributes = @{
                                          NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                          NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                          };
    NSDictionary *legalTextHighlightAttributes = @{
                                                   NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                                   NSForegroundColorAttributeName: [[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey] colorWithAlphaComponent:0.5f],
                                                   };
    NSMutableAttributedString *attributedLegalText = [[NSMutableAttributedString alloc] initWithString:fullLegalText
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

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([VPromptCarouselViewController class])])
    {
        VPromptCarouselViewController *carouselController = segue.destinationViewController;
        [carouselController setDependencyManager:self.dependencyManager];
    }
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
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedTwitterAuthorizationWithCompletion:)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in the responder chain for registerring.");
    }
    [flowControllerResponder selectedTwitterAuthorizationWithCompletion:nil];
}

- (IBAction)loginWithFacebook:(id)sender
{
    id<VLoginFlowControllerResponder> flowControllerResponder = [self targetForAction:@selector(selectedFacebookAuthorizationWithCompletion:)
                                                                           withSender:self];
    if (flowControllerResponder == nil)
    {
        NSAssert(false, @"We need a flow controller in teh respodner chain for facebook.");
    }
    [flowControllerResponder selectedFacebookAuthorizationWithCompletion:^(BOOL success)
    {
        if (!success)
        {
            NSString *message = NSLocalizedString(@"FacebookLoginFailed", @"");
            [self showErrorWithMessage:message];
        }
    }];
}

#pragma mark - Helpers

- (void)showErrorWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
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
    [self.view setNeedsLayout];
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
