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

static NSString * const kStoryboardName = @"PermissionAlert";
static NSString * const kConfirmButtonTitleKey = @"title.button1";
static NSString * const kCancelButtonTitleKey = @"title.button2";

@interface VPermissionAlertViewController () <VBackgroundContainer>

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (strong, nonatomic) VPermissionAlertTransitionDelegate *transitionDelegate;

@property (weak, nonatomic) IBOutlet UIView *alertContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet VButtonWithCircularEmphasis *confirmationButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

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
    
    self.messageLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.messageLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    NSString *message = [self.dependencyManager stringForKey:VDependencyManagerTitleKey];
    if (!message || message.length == 0)
    {
       message = NSLocalizedString(@"We hope to connect and communicate with our fans. By having a profile picture, we will be able to recognize you!\n\nWould you like to take a profile picture?", nil);
    }
    self.messageLabel.text = message;
    
    [self.confirmationButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton1FontKey]];
    [self.confirmationButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerLinkColorKey] forState:UIControlStateNormal];
    [self.confirmationButton setTitle:@"Okay!" forState:UIControlStateNormal];
    [self.confirmationButton setEmphasisColor:[self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]];
    NSString *confirmButtonTitle = [self.dependencyManager stringForKey:kConfirmButtonTitleKey];
    if (!confirmButtonTitle || confirmButtonTitle.length == 0)
    {
        confirmButtonTitle = NSLocalizedString(@"Okay!", @"");
    }
    [self.confirmationButton setTitle:confirmButtonTitle forState:UIControlStateNormal];
    
    [self.cancelButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton2FontKey]];
    [self.cancelButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey] forState:UIControlStateNormal];
    NSString *cancelButtonTitle = [self.dependencyManager stringForKey:kCancelButtonTitleKey];
    if (!cancelButtonTitle || cancelButtonTitle.length == 0)
    {
        cancelButtonTitle = NSLocalizedString(@"Maybe Later", @"");
    }
    [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
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

#pragma mark - Background

- (UIView *)backgroundContainerView
{
    return self.alertContainerView;
}

@end
