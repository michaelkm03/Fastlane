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
#import "victorious-Swift.h"
#import "VLaunchScreenProvider.h"

#import <SDWebImage/UIImageView+WebCache.h>

@import KVOController;

static const NSTimeInterval levelProgressAnimationTime = 2;
static const CGFloat kMinimumBlurredImageSize = 50.0;
static NSString * const kLevelBadgeKey = @"animatedBadge";

@interface VStaticUserProfileHeaderViewController ()

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
    
    // Setup badge view
    [self updateBadgeView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateBadgeView];
}

#pragma mark - Helpers

- (void)updateBadgeView
{
    if ( ![self isViewLoaded] )
    {
        //This prevents unnecessary badge updating and animation,
        //which can stall animations elsehwere in the app, from occurring
        return;
    }
    
    if ([self badgeViewNeedsToBeUpdated])
    {
        // Remove all subviews from badge container view
        NSArray *badgeContainerSubviews = [self.badgeContainerView.subviews copy];
        for (UIView *view in badgeContainerSubviews)
        {
            [view removeFromSuperview];
        }
        
        UIView *viewToContain = [self configuredBadgeView];
        if (viewToContain != nil)
        {
            [self.badgeContainerView addSubview:viewToContain];
            [self.badgeContainerView v_addFitToParentConstraintsToSubview:viewToContain];
            // Otherwise the badge's shape layer won't always animate it's stroke
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [self animateProgress];
            });
        }
    }
}

- (void)animateProgress
{
    if (self.state == VUserProfileHeaderStateCurrentUser)
    {
        NSInteger progress = self.user.levelProgressPercentage.integerValue;
        [self.badgeView animateProgress:levelProgressAnimationTime * (progress / 100.0f) endPercentage:progress completion:nil];
    }
}

- (UIView *)configuredBadgeView
{
    AnimatedBadgeView *animatedBadgeView = [self.dependencyManager templateValueOfType:[AnimatedBadgeView class] forKey:kLevelBadgeKey];
    
    // We have no badge component or user
    if (animatedBadgeView == nil || self.user == nil)
    {
        return nil;
    }
    
    // Make sure we have a badge component and that this user is a high enough level to show it
    if (self.user.level.integerValue > 0 && self.user.level.integerValue >= animatedBadgeView.minLevel)
    {
        if (self.user.isCreator.boolValue)
        {
            return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level_badge_creator_large"]];
        }
        else
        {
            self.badgeView = animatedBadgeView;
            self.badgeView.cornerRadius = 4;
            self.badgeView.animatedBorderWidth = 3;
            self.badgeView.progressBarInset = 3;
            self.badgeView.levelNumberLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
            self.badgeView.levelStringLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:8];
            self.badgeView.levelNumberString = self.user.level.stringValue;
            return self.badgeView;
        }
    }
        
    return nil;
}

- (BOOL)badgeViewNeedsToBeUpdated
{
    return ![self.badgeView.levelNumberString isEqualToString:self.user.level.stringValue] ||
    self.badgeView.progress != self.user.levelProgressPercentage.integerValue ||
    self.badgeView.superview == nil;
}

#pragma mark - VUserProfileHeader

- (CGFloat)preferredHeight
{
    return 319.0f;
}

#pragma mark - VAbstractUserProfileHeaderViewController overrides

- (void)userHasChanged
{
    // We have a new user, update badge view
    [self updateBadgeView];

    __weak typeof(self) welf = self;
    
    // If user level changes, make sure to update the badge
    [self.KVOController observe:self.user
                       keyPaths:@[ NSStringFromSelector(@selector(level)),
                                   NSStringFromSelector(@selector(levelProgressPercentage)) ]
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateBadgeView];
     }];
}

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
    UIImage *launchScreenImage = [[VLaunchScreenProvider launchImage] scaleToSize:[UIScreen mainScreen].bounds.size];
    
    [self.backgroundImageView setBlurredImageWithClearImage:launchScreenImage
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
