//
//  VModernLandingViewController.m
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernLandingViewController.h"

// Views + Helpers
#import "VLoginFlowControllerDelegate.h"
#import "UIView+AutoLayout.h"
#import "UIAlertController+VSimpleAlert.h"
#import "victorious-Swift.h"

// ViewControllers
#import "VPromptCarouselViewController.h"

// Dependencies
#import "VDependencyManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VTracking.h"

@import CoreText;

static NSString * const kSigninOptionsKey = @"signInOptions";
static NSString * const kLogoKey = @"logo";
static NSString * const kStatusBarStyle = @"statusBarStyle";
static NSString * const kEmailKey = @"email";
static NSString * const kFacebookKey = @"facebook";

static CGFloat const kLoginButtonToTextViewSpacing = 8.0f;

@interface VModernLandingViewController () <VBackgroundContainer, VLoginFlowScreen>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIButton *emailButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UILabel *legalIntroLabel;
@property (nonatomic, strong) IBOutlet UIButton *termsOfServiceButton;
@property (nonatomic, strong) IBOutlet UIButton *privacyPolicyButton;
@property (nonatomic, strong) IBOutlet UIView *legalButtonContainer;

@property (nonatomic, strong) UIBarButtonItem *loginButton;

@end

@implementation VModernLandingViewController

@synthesize delegate = _delegate;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VModernLandingViewController *landingViewController = [[UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                                     bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
    landingViewController.dependencyManager = dependencyManager;
    return landingViewController;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.loginButton.enabled = YES; 
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSigninOptions];
    
    UIImage *headerImage = [self.dependencyManager imageForKey:kLogoKey];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:headerImage];
    self.navigationItem.titleView = headerImageView;
    
    self.loginButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", @"")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(login)];
    self.navigationItem.rightBarButtonItem = self.loginButton;
    
    NSDictionary *legalAttributes = @{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                      NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]};
    NSDictionary *legalAttributesWithUnderline = @{
                                                   NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                                   NSForegroundColorAttributeName: [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
                                                   NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                   };
    
    NSAttributedString *legalIntoText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"By signing up you are agreeing to our", nil)
                                                                        attributes:legalAttributes];
    NSAttributedString *tosText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Terms of Service", nil)
                                                                  attributes:legalAttributesWithUnderline];
    NSAttributedString *ppText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Privacy Policy", nil)
                                                                 attributes:legalAttributesWithUnderline];
    self.legalIntroLabel.attributedText = legalIntoText;
    [self.termsOfServiceButton setAttributedTitle:tosText forState:UIControlStateNormal];
    [self.privacyPolicyButton setAttributedTitle:ppText forState:UIControlStateNormal];
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.emailButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationEmail;
    self.facebookButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationFacebook;
    self.termsOfServiceButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationTOS;
    self.privacyPolicyButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationPrivacy;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    self.loginButton.enabled = NO;
    [self.delegate selectedLogin];
}

- (IBAction)toRegsiter:(id)sender
{
    [self.delegate selectedRegister];
}

- (IBAction)loginWithFacebook:(id)sender
{
    [self.delegate selectedFacebookAuthorization];
}

- (IBAction)showTermsOfService:(id)sender
{
    [self.delegate showTermsOfService];
}

- (IBAction)showPrivacyPolicy:(id)sender
{
    [self.delegate showPrivacyPolicy];
}

#pragma mark - Helpers

- (void)showErrorWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController simpleAlertControllerWithTitle:NSLocalizedString(@"LoginFail", @"")
                                                                         message:message
                                                            andCancelButtonTitle:NSLocalizedString(@"OK", @"")];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

#pragma mark - Internal Methods

- (void)setupSigninOptions
{
    self.facebookButton.hidden = YES;
    self.emailButton.hidden = YES;
    
    NSArray *options = [self.dependencyManager arrayOfValuesOfType:[NSString class] forKey:kSigninOptionsKey];
    
    options = [options filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings)
    {
        return [self buttonForLoginType:evaluatedObject] != nil && (VFacebookHelper.facebookAppIDPresent || ![evaluatedObject isEqualToString:kFacebookKey]);
    }]];
    
    for (NSUInteger idx = 0; idx < options.count; idx++)
    {
        NSString *currentLoginType = options[idx];
        UIButton *currentButton = [self buttonForLoginType:currentLoginType];
        currentButton.hidden = NO;
        if (idx > 0)
        {
            NSString *previousLoginType = options[idx - 1];
            UIButton *previousButton = [self buttonForLoginType:previousLoginType];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:previousButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:currentButton
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
    else
    {
        return nil;
    }
}

@end
