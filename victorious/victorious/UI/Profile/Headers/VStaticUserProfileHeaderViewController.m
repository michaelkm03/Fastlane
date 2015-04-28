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

#import <SDWebImage/UIImageView+WebCache.h>

@interface VStaticUserProfileHeaderViewController ()

@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *staticProfileImageView;

@end

@implementation VStaticUserProfileHeaderViewController

@synthesize loading = _isLoading;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - VUserProfileHeader

- (CGFloat)preferredHeight
{
    return 319.0f;
}

#pragma mark - VUserProfileHeaderViewController overrides

- (VDefaultProfileImageView *)profileImageView
{
    return self.staticProfileImageView;
}

- (void)loadBackgroundImageFromURL:(NSURL *)imageURL
{
    if ( ![self.backgroundImageView.sd_imageURL isEqual:imageURL] )
    {
        [self.backgroundImageView applyTintAndBlurToImageWithURL:imageURL withTintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    }
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setBlurredImageWithClearImage:[UIImage imageNamed:@"Default"]
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
            [self.primaryActionButton setStyle:VButtonStyleSecondary];
            [self.primaryActionButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
            break;
        case VUserProfileHeaderStateNotFollowingUser:
            [self.primaryActionButton setStyle:VButtonStylePrimary];
            [self.primaryActionButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)setLoading:(BOOL)loading
{
     _isLoading = loading;
    
    if ( _isLoading )
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
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
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
    
    self.userStatsBar.backgroundColor = backgroundColor;
}

@end
