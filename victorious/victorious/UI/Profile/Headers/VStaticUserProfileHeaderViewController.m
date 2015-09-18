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

static const NSTimeInterval levelProgressAnimationTime = 2;
static const CGFloat kMinimumBlurredImageSize = 50.0;
static NSString * const kLevelBadgeKey = @"animatedBadge";

@interface VStaticUserProfileHeaderViewController ()

@property (nonatomic, assign) BOOL hasAppeared;

@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *staticProfileImageView;

@property (weak, nonatomic) IBOutlet UIView *badgeContainerView;
@property (nonatomic, strong) AnimatedBadgeView *badgeView;

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
    
    [self setupBadgeView];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasAppeared)
    {
        self.hasAppeared = YES;
        if ([[[VObjectManager sharedManager] mainUser] isEqual:self.user])
        {
            // Animate progress towards next level for current user's profile
            CGFloat progressRatio = self.user.levelProgressPercentage.floatValue / 100;
            [self.badgeView animateProgress:levelProgressAnimationTime endValue:progressRatio];
        }
    }
}

#pragma mark - Helpers

- (void)setupBadgeView
{
    self.badgeView = [self.dependencyManager templateValueOfType:[AnimatedBadgeView class] forKey:kLevelBadgeKey];
    self.badgeView.cornerRadius = 8;
    self.badgeView.animatedBorderWidth = 2;
    self.badgeView.progressBarInset = 3;
    self.badgeView.title = NSLocalizedString(@"LEVEL", "");
    self.badgeView.levelNumberLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    self.badgeView.levelStringLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:8];
    self.badgeView.levelNumber = [self.user.level stringValue];
    [self.badgeContainerView addSubview:self.badgeView];
    [self.badgeContainerView v_addFitToParentConstraintsToSubview:self.badgeView];
}

- (void)adjustLevelBadgeProgressAnimated:(BOOL)animated
{
    
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
