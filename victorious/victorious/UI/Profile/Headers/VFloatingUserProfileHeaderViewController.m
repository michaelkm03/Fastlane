//
//  VFloatingUserProfileHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFloatingUserProfileHeaderViewController.h"
#import "VDependencyManager.h"
#import "VDefaultProfileImageView.h"
#import "VLinearGradientView.h"
#import "VButton.h"
#import "UIView+AutoLayout.h"

static const CGFloat kFloatProfileImageSize = 57.0f;

@interface VFloatingUserProfileHeaderViewController ()

@property (nonatomic, weak) IBOutlet VLinearGradientView *gradientView;
@property (nonatomic, weak) IBOutlet VButton *secondaryActionButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *primaryActionButtonHeightConstraint;
@property (nonatomic, assign) CGFloat primaryActionButtonStartHeight;
@property (nonatomic, strong) VDefaultProfileImageView *floatingProfileImageView;

@end

@implementation VFloatingUserProfileHeaderViewController

- (void)loadView
{
    CGRect profileFrame = CGRectMake( 0, 0, kFloatProfileImageSize, kFloatProfileImageSize );
    self.floatingProfileImageView = [[VDefaultProfileImageView alloc] initWithFrame:profileFrame];
    
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gradientView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.gradientView.colors = @[ [UIColor clearColor], [UIColor blackColor] ];
    self.gradientView.locations = @[ @0.3f, @0.75f ];
    
    self.primaryActionButtonStartHeight = self.primaryActionButtonHeightConstraint.constant;
    self.primaryActionButtonHeightConstraint.constant = 0;
    [self.primaryActionButton layoutIfNeeded];
    
    self.secondaryActionButton.hidden = YES;
    
    self.state = self.state;
}

#pragma mark - VUserProfileHeader

- (CGFloat)preferredHeight
{
    return 374.0f;
}

- (VDefaultProfileImageView *)profileImageView
{
    return self.floatingProfileImageView;
}

- (UIView *)floatingProfileImage
{
    return self.floatingProfileImageView;
}

#pragma mark - Actions

- (IBAction)pressedSecondaryAction:(id)sender
{
    [self.delegate primaryActionHandler];
}

#pragma mark - VUserProfileHeaderViewController overrides- (void)setState:(VUserProfileHeaderState)state

- (void)setState:(VUserProfileHeaderState)state
{
    super.state = state;
    
    switch ( state )
    {
        case VUserProfileHeaderStateCurrentUser:
            self.secondaryActionButton.hidden = YES;
            [self.primaryActionButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
            self.primaryActionButtonHeightConstraint.constant = self.primaryActionButtonStartHeight;
            break;
        case VUserProfileHeaderStateFollowingUser:
            [self.secondaryActionButton setImage:[UIImage imageNamed:@"profile_followed_icon"] forState:UIControlStateNormal];
            self.secondaryActionButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
            self.secondaryActionButton.hidden = NO;
            self.primaryActionButtonHeightConstraint.constant = 0;
            break;
        case VUserProfileHeaderStateNotFollowingUser:
            [self.secondaryActionButton setImage:[UIImage imageNamed:@"profile_follow_icon"] forState:UIControlStateNormal];
            self.secondaryActionButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
            self.secondaryActionButton.hidden = NO;
            self.primaryActionButtonHeightConstraint.constant = 0;
            break;
        default:
            break;
    }
    
    [self.primaryActionButton layoutIfNeeded];
}

- (void)setIsLoading:(BOOL)isLoading
{
    if ( isLoading )
    {
        [self.secondaryActionButton showActivityIndicator];
        self.secondaryActionButton.enabled = NO;
    }
    else
    {
        [self.secondaryActionButton hideActivityIndicator];
        self.secondaryActionButton.enabled = YES;
    }
}

- (void)applyStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    [super applyStyleWithDependencyManager:dependencyManager];
    
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    UIColor *contentTextColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    UIColor *accentColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *secondaryLinkColor = [dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey];
    
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = secondaryLinkColor.CGColor;
    self.profileImageView.tintColor = linkColor;
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    
    self.primaryActionButton.primaryColor = secondaryLinkColor;
    self.primaryActionButton.secondaryColor = secondaryLinkColor;
    self.primaryActionButton.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    [self.primaryActionButton setStyle:VButtonStyleSecondary];
    
    self.secondaryActionButton.layer.borderWidth = 2.0f;
    self.secondaryActionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.secondaryActionButton.layer.cornerRadius = CGRectGetHeight( self.secondaryActionButton.bounds ) / 2.0f;
    
    self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.nameLabel.textColor = textColor;
    
    self.locationLabel.font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    self.locationLabel.textColor = contentTextColor;
    
    self.taglineLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.taglineLabel.textColor = textColor;
    
    self.followersLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = textColor;
    
    self.followersHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = textColor;
    
    self.followingLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = textColor;
    
    self.followingHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = textColor;
    
    self.userStatsBar.backgroundColor = accentColor;
}

@end
