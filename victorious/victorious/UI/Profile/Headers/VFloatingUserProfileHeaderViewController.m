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
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *primaryActionButtonTopConstraint;
@property (nonatomic, assign) CGFloat primaryActionButtonStartTop;
@property (nonatomic, strong) VDefaultProfileImageView *floatingProfileImageView;

@end

@implementation VFloatingUserProfileHeaderViewController

@synthesize loading = _loading;

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
    
    self.primaryActionButtonStartTop = self.primaryActionButtonTopConstraint.constant;
    self.primaryActionButtonStartHeight = self.primaryActionButtonHeightConstraint.constant;
    
    [self setPrimaryActionButtonHidden:YES];
    
    self.secondaryActionButton.hidden = YES;
    
    if ( self.state != VUserProfileHeaderStateUndefined )
    {
        self.state = self.state; // Trigger a state refresh
    }
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

#pragma mark - VUserProfileHeaderViewController overrides

- (void)setState:(VUserProfileHeaderState)state
{
    super.state = state;
    
    switch ( state )
    {
        case VUserProfileHeaderStateCurrentUser:
            self.secondaryActionButton.hidden = YES;
            [self.primaryActionButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
            [self setPrimaryActionButtonHidden:NO];
            break;
        case VUserProfileHeaderStateFollowingUser:
            [self.secondaryActionButton setImage:[UIImage imageNamed:@"profile_followed_icon"] forState:UIControlStateNormal];
            self.secondaryActionButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
            self.secondaryActionButton.hidden = NO;
            [self setPrimaryActionButtonHidden:YES];
            break;
        case VUserProfileHeaderStateNotFollowingUser:
            [self.secondaryActionButton setImage:[UIImage imageNamed:@"profile_follow_icon"] forState:UIControlStateNormal];
            self.secondaryActionButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
            self.secondaryActionButton.hidden = NO;
            [self setPrimaryActionButtonHidden:YES];
            break;
        default:
            break;
    }
}

- (void)setPrimaryActionButtonHidden:(BOOL)hidden
{
    self.primaryActionButtonHeightConstraint.constant = hidden ? 0 : self.primaryActionButtonStartHeight;
    self.primaryActionButtonTopConstraint.constant = hidden ? 0 : self.primaryActionButtonStartTop;
    [self.primaryActionButton layoutIfNeeded];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if ( _loading )
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

- (void)applyStyle
{
    [super applyStyle];
    
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    UIColor *contentTextColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    UIColor *accentColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *secondaryLinkColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey];
    
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = secondaryLinkColor.CGColor;
    self.profileImageView.tintColor = linkColor;
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    
    self.primaryActionButton.primaryColor = secondaryLinkColor;
    self.primaryActionButton.secondaryColor = secondaryLinkColor;
    self.primaryActionButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    [self.primaryActionButton setStyle:VButtonStyleSecondary];
    
    self.secondaryActionButton.layer.borderWidth = 2.0f;
    self.secondaryActionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.secondaryActionButton.layer.cornerRadius = CGRectGetHeight( self.secondaryActionButton.bounds ) / 2.0f;
    
    self.nameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    self.nameLabel.textColor = textColor;
    
    self.locationLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    self.locationLabel.textColor = contentTextColor;
    
    self.taglineLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.taglineLabel.textColor = textColor;
    
    self.followersLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = textColor;
    
    self.followersHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = textColor;
    
    self.followingLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = textColor;
    
    self.followingHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = textColor;
    
    self.userStatsBar.backgroundColor = accentColor;
}

@end
