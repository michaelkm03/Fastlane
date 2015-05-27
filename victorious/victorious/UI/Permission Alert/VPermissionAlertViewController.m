//
//  VPermissionAlertViewController.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertViewController.h"
#import "VDependencyManager.h"
#import "VBackgroundContainer.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VButtonWithCircularEmphasis.h"
#import "VPermissionAlertAnimator.h"
#import "VRoundedImageView.h"
#import "VAppInfo.h"

@import CoreText;

static const CGFloat kMaxAlertHeightDifferenceFromSuperview = 100.0f;

static NSString * const kStoryboardName = @"PermissionAlert";
static NSString * const kConfirmButtonTitleKey = @"title.button1";
static NSString * const kDenyButtonTitleKey = @"title.button2";

@interface VPermissionAlertViewController () <VBackgroundContainer>

@property (strong, nonatomic) VDependencyManager *dependencyManager;

@property (strong, nonatomic) VPermissionAlertTransitionDelegate *transitionDelegate;

@property (weak, nonatomic) IBOutlet UIView *alertContainerView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet VButtonWithCircularEmphasis *confirmationButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet VRoundedImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation VPermissionAlertViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    VPermissionAlertViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
        _transitionDelegate = [[VPermissionAlertTransitionDelegate alloc] init];
        self.transitioningDelegate = _transitionDelegate;
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.alertContainerView.layer.cornerRadius = 24.0f;
    self.alertContainerView.clipsToBounds = YES;
    
    self.messageTextView.editable = NO;
    self.messageTextView.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.messageTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.messageTextView.text = self.messageText;
    
    self.confirmButtonText = [self.dependencyManager stringForKey:kConfirmButtonTitleKey];
    self.denyButtonText = [self.dependencyManager stringForKey:kDenyButtonTitleKey];
    
    [self.confirmationButton setTitle:self.confirmButtonText forState:UIControlStateNormal];
    [self.confirmationButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton1FontKey]];
    [self.confirmationButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] forState:UIControlStateNormal];
    [self.confirmationButton setEmphasisColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]];
    
    [self.denyButton setTitle:self.denyButtonText forState:UIControlStateNormal];
    [self.denyButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton2FontKey]];
    [self.denyButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey] forState:UIControlStateNormal];
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    [self.iconImageView setIconImageURL:appInfo.profileImageURL];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    [self.view setNeedsUpdateConstraints];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateViewConstraints
{
    // Get total height of all other views
    CGFloat totalHeight = self.topConstraint.constant;
    totalHeight += CGRectGetHeight(self.iconImageView.bounds);
    totalHeight += self.middleConstraint.constant;
    totalHeight += self.bottomConstraint.constant;
    totalHeight += CGRectGetHeight(self.confirmationButton.bounds);
    
    // Get the maximum height of the alert view
    CGFloat maxHeight = CGRectGetHeight(self.view.bounds) - kMaxAlertHeightDifferenceFromSuperview;
    
    // Create temporary text view and size to fit the text
    UITextView *temporary = [[UITextView alloc] initWithFrame:self.messageTextView.bounds];
    temporary.font = self.messageTextView.font;
    temporary.text = self.messageText;
    [temporary sizeToFit];
    
    // Calculate text height. add 15 to make sure custom fonts dont get clipped
    CGFloat textHeight = ceil(CGRectGetHeight(temporary.bounds)) + 15;
    
    // Find out how high the text view should be
    CGFloat newTextViewConstant = 0;
    if (textHeight + totalHeight < maxHeight)
    {
        newTextViewConstant = textHeight;
        self.messageTextView.scrollEnabled = NO;
    }
    else
    {
        newTextViewConstant = maxHeight - totalHeight;
        self.messageTextView.scrollEnabled = YES;
    }
    
    // Set the text view height
    self.textViewHeightConstraint.constant = newTextViewConstant;
    
    [self.messageTextView setContentOffset:CGPointZero];
    
    [super updateViewConstraints];
}

#pragma mark - Properties

- (NSString *)messageText
{
    if (_messageText == nil || _messageText.length == 0)
    {
        return NSLocalizedString(@"We need access to this permission.", nil);
    }
    
    return _messageText;
}

- (NSString *)confirmButtonText
{
    if (_confirmButtonText == nil || _confirmButtonText.length == 0)
    {
        return NSLocalizedString(@"Okay!", nil);
    }
    
    return _confirmButtonText;
}

- (NSString *)denyButtonText
{
    if (_denyButtonText == nil || _denyButtonText.length == 0)
    {
        return NSLocalizedString(@"Maybe Later", nil);
    }
    
    return _denyButtonText;
}

#pragma mark - Actions

- (IBAction)pressedConfirm:(id)sender
{
    if (self.confirmationHandler != nil)
    {
        self.confirmationHandler(self);
    }
}

- (IBAction)pressedDeny:(id)sender
{
    if (self.denyHandler != nil)
    {
        self.denyHandler(self);
    }
}

- (IBAction)pressedBackground:(id)sender
{
    if (self.denyHandler != nil)
    {
        self.denyHandler(self);
    }
}

#pragma mark - Background

- (UIView *)backgroundContainerView
{
    return self.alertContainerView;
}

@end
