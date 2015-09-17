//
//  VStaticUserProfileHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStaticUserProfileHeaderViewController.h"
#import "VDependencyManager+VUserProfile.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageCreation.h"
#import "VButton.h"
#import "VDefaultProfileImageView.h"
#import "victorious-swift.h"

#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kMinimumBlurredImageSize = 50.0;

@interface VStaticUserProfileHeaderViewController ()

@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *staticProfileImageView;
@property (weak, nonatomic) IBOutlet ProfileBadgeView *badgeView;

@end

@implementation VStaticUserProfileHeaderViewController

@synthesize loading = _loading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.primaryActionButton.alpha = 0.0f;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if ( self.state != VUserProfileHeaderStateUndefined )
    {
        self.state = self.state; // Trigger a state refresh
    }
    
    self.badgeView.color = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    self.badgeView.levelNumberLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.badgeView.levelStringLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:8];
    self.badgeView.levelNumber = @"100";
    self.badgeView.title = @"LEVEL";
    self.badgeView.cornerRadius = 2;
    self.badgeView.borderWidth = 2;
    [self.badgeView animate:2.0 startValue:0 endValue:1.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - VUserProfileHeader

- (CGFloat)preferredHeight
{
    return 319.0f;
}

#pragma mark - VAbstractUserProfileHeaderViewController overrides

- (VDefaultProfileImageView *)profileImageView
{
    return self.staticProfileImageView;
}

- (void)reloadProfileImage
{
    [self.backgroundImageView clearDownloadCache];
    [self updateProfileImage];
}

- (void)updateProfileImage
{
    CGSize minimumSize = CGSizeMake( kMinimumBlurredImageSize, kMinimumBlurredImageSize );
    NSURL *imageURL = [self getBestAvailableImageForMinimuimSize:minimumSize];
    if ( imageURL == nil || imageURL.absoluteString.length == 0 )
    {
        [self clearBackgroundImage];
    }
    else if ( ![self.backgroundImageView.sd_imageURL isEqual:imageURL] )
    {
        [self.backgroundImageView applyTintAndBlurToImageWithURL:imageURL
                                                   withTintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    }
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setBlurredImageWithClearImage:[UIImage imageNamed:@"LaunchImage"]
                                           placeholderImage:nil
                                                  tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f]];
}

- (void)setState:(VUserProfileHeaderState)state
{
    super.state = state;
    
    switch ( state )
    {
        case VUserProfileHeaderStateCurrentUser:
            [self.primaryActionButton setStyle:VButtonStyleSecondary];
            [self.primaryActionButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
            break;
        case VUserProfileHeaderStateFollowingUser:
            [self.primaryActionButton setStyle:VButtonStylePrimary];
            [self.primaryActionButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
            break;
        case VUserProfileHeaderStateNotFollowingUser:
            [self.primaryActionButton setStyle:VButtonStyleSecondary];
            [self.primaryActionButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
            break;
        default:
            return;
    }
    
    [self revealStatefulUIElements];
}

- (void)revealStatefulUIElements
{
    // `primaryActionButton` is invisible when this view first loads so that it doesnt not display
    // until an accurate state is set in this `setState:` method.  Once that's done above, now we can show it
    self.primaryActionButton.hidden = NO;
    [UIView animateWithDuration:0.35f animations:^
     {
         self.primaryActionButton.alpha = 1.0f;
     }];
}

- (void)setLoading:(BOOL)loading
{
     _loading = loading;
    
    if ( _loading )
    {
        [self.primaryActionButton showActivityIndicator];
        self.primaryActionButton.enabled = NO;
    }
    else
    {
        [self.primaryActionButton hideActivityIndicator];
        self.primaryActionButton.enabled = YES;
    }
}

- (void)applyStyle
{
    [super applyStyle];
    
    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = linkColor.CGColor;
    self.profileImageView.tintColor = linkColor;
    self.profileImageView.backgroundColor = [UIColor whiteColor];
    
    self.primaryActionButton.primaryColor = linkColor;
    self.primaryActionButton.secondaryColor = linkColor;
    self.primaryActionButton.titleLabel.font = [self.self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    
    self.nameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.nameLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.locationLabel.font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    
    self.taglineLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.taglineLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.followersLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = textColor;
    
    self.followersHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = textColor;
    
    self.followingLabel.font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = textColor;
    
    self.followingHeader.font = [self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = textColor;
}

@end
