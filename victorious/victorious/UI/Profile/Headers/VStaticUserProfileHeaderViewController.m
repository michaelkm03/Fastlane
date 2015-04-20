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

@property (nonatomic, readonly) VButton *primaryActionButton;

@end

@implementation VStaticUserProfileHeaderViewController

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

- (void)applyProfileImageViewStyle
{
    self.profileImageView.layer.borderWidth = 2.0;
}

- (VButton *)primaryActionButton
{
    return (VButton *)super.primaryActionButton;
}

- (void)loadBackgroundImage:(NSURL *)imageURL
{
    UIImage *placeholderImage = self.backgroundImageView.image;
    if ( placeholderImage == nil )
    {
        placeholderImage = [[UIImage resizeableImageWithColor:[self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]] applyLightEffect];
    }
    
    if ( ![self.backgroundImageView.sd_imageURL isEqual:imageURL] )
    {
        [self.backgroundImageView setBlurredImageWithURL:imageURL
                                        placeholderImage:placeholderImage
                                               tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    }
}

- (void)setIsLoading:(BOOL)isLoading
{
    [super setIsLoading:isLoading];
    
    if ( isLoading )
    {
        [self.primaryActionButton showActivityIndicator];
    }
    else
    {
        [self.primaryActionButton hideActivityIndicator];
    }
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setBlurredImageWithClearImage:[UIImage imageNamed:@"Default"]
                                           placeholderImage:nil
                                                  tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f]];
}

- (void)applyCurrentUserStyle
{
    [self.primaryActionButton setStyle:VButtonStyleSecondary];
    self.primaryActionButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.primaryActionButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.primaryActionButton setTitle:NSLocalizedString(@"self.primaryActionButton", @"") forState:UIControlStateNormal];
}

- (void)applyFollowingStyle
{
    [self.primaryActionButton setStyle:VButtonStyleSecondary];
    self.primaryActionButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.primaryActionButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.primaryActionButton setTitle:NSLocalizedString(@"self.primaryActionButton", @"") forState:UIControlStateNormal];
}

- (void)applyNotFollowingStyle
{
    [self.primaryActionButton setStyle:VButtonStylePrimary];
    self.primaryActionButton.primaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.primaryActionButton.secondaryColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.primaryActionButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
}

- (void)applyAllStatesEditButtonStyle
{
    UIFont *buttonFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.primaryActionButton.titleLabel.font = buttonFont;
    
    if ( [[self.dependencyManager stringForKey:VDependencyManagerProfileEditButtonStyleKey] isEqualToString:VDependencyManagerProfileEditButtonStylePill] )
    {
        self.primaryActionButton.cornerRadius = CGRectGetHeight( self.primaryActionButton.bounds ) / 2.0f;
    }
}

- (void)applyStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    
    self.profileImageView.layer.borderColor = linkColor.CGColor;
    
    self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.locationLabel.font = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    
    self.taglineLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.taglineLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.followersLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = textColor;
    
    self.followersHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = textColor;
    
    self.followingLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = textColor;
    
    self.followingHeader.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = textColor;
    
    UIColor *backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.userStatsBar.backgroundColor = backgroundColor;
    
    [self applyAllStatesEditButtonStyle];
}

@end
