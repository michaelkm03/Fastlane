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

@interface VFloatingUserProfileHeaderViewController ()

@property (nonatomic, weak) IBOutlet VLinearGradientView *gradientView;

@end

@implementation VFloatingUserProfileHeaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gradientView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
    self.gradientView.colors = @[ [UIColor clearColor], [UIColor blackColor] ];
    self.gradientView.locations = @[ @0.3f, @0.75f ];
}

#pragma mark - VUserProfileHeader

- (CGFloat)preferredHeight
{
    return 374.0f;
}

#pragma mark - VUserProfileHeaderViewController overrides

- (void)applyProfileImageViewStyle
{
    self.profileImageView.layer.borderWidth = 2.0;
}

- (void)applyCurrentUserStyle
{
}

- (void)applyFollowingStyle
{
}

- (void)applyNotFollowingStyle
{
}

- (void)applyAllStatesEditButtonStyle
{
    self.primaryActionButton.layer.borderWidth = 2.0f;
    self.primaryActionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.primaryActionButton.layer.cornerRadius = CGRectGetHeight( self.primaryActionButton.bounds ) / 2.0f;
    self.primaryActionButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

- (void)applyStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIColor *linkColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
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
    
    self.userStatsBar.backgroundColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    
    [self applyAllStatesEditButtonStyle];
}

@end
