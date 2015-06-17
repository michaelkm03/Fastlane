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
#import "VUser.h"
#import "UIImageView+Blurring.h"

#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kBlurredWhiteAlpha = 0.5f;
static const CGFloat kFloatProfileImageSize = 57.0f;

@interface VFloatingUserProfileHeaderViewController ()

@property (nonatomic, weak) IBOutlet VLinearGradientView *gradientView;
@property (nonatomic, weak) IBOutlet VButton *secondaryActionButton;
@property (nonatomic, weak) IBOutlet UIView *usersStatusDivider;
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
    
    self.gradientView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    self.gradientView.colors = @[ [UIColor clearColor], [UIColor blackColor] ];
    self.gradientView.locations = @[ @0.5f, @1.0f ];
    self.gradientView.alpha = 0.65f;
    
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

#pragma mark - VAbstractUserProfileHeaderViewController overrides

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
            if ( self.secondaryActionButton.hidden )
            {
                [self animateTransitionInWithButton:self.secondaryActionButton];
            }
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

- (void)reloadProfileImage
{
    [self.backgroundImageView clearDownloadCache];
    [self updateProfileImage];
}

- (void)updateProfileImage
{
    NSURL *imageURL = [self getBestAvailableImageForMinimuimSize:self.view.bounds.size];
    if ( imageURL == nil || imageURL.absoluteString.length == 0 )
    {
        [self.backgroundImageView setBlurredImageWithClearImage:[UIImage imageNamed:@"LaunchImage"]
                                               placeholderImage:nil
                                                      tintColor:[UIColor colorWithWhite:0.0 alpha:kBlurredWhiteAlpha]];
    }
    else if ( ![self.backgroundImageView.sd_imageURL isEqual:imageURL] )
    {
        [self.backgroundImageView sd_setImageWithURL:imageURL placeholderImage:nil completed:nil];
    }
}

- (void)animateTransitionInWithButton:(UIButton *)button
{
    self.secondaryActionButton.alpha = 0.0f;
    self.secondaryActionButton.transform = CGAffineTransformMakeScale( 0.1f, 0.1f );
    [UIView animateWithDuration:0.5f
                          delay:0.4f
         usingSpringWithDamping:0.65f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^
     {
         self.secondaryActionButton.transform = CGAffineTransformMakeScale( 1.0f, 1.0f );
         self.secondaryActionButton.alpha = 1.0f;
     } completion:nil];
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
    UIColor *secondaryTextColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
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
    self.locationLabel.textColor = secondaryTextColor;
    
    self.taglineLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.taglineLabel.textColor = textColor;
    
    self.followersLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = contentTextColor;
    
    self.followersHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = contentTextColor;
    
    self.followingLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = contentTextColor;
    
    self.followingHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = contentTextColor;
    
    self.usersStatusDivider.backgroundColor = [contentTextColor colorWithAlphaComponent:0.45f];
}

@end
