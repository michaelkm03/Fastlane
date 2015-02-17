//
//  VFollowerTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowerTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VThemeManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface      VFollowerTableViewCell ()

@property (nonatomic, weak)     IBOutlet    UIImageView        *profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileName;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileLocation;

@property (nonatomic, strong) UIImage *followImage;
@property (nonatomic, strong) UIImage *unfollowImage;

@end

@implementation VFollowerTableViewCell

- (void)setProfile:(VUser *)profile
{
    _profile = profile;

    //UIImage *sImg = [[UIImage imageNamed:@"buttonFollow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.followImage   = [[UIImage imageNamed:@"buttonFollow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.unfollowImage = [UIImage imageNamed:@"buttonFollowed"];
    
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString: profile.pictureUrl]
                         placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileImage.layer.cornerRadius = CGRectGetHeight(self.profileImage.bounds)/2;
    self.profileImage.layer.borderWidth = 1.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
    
    self.profileName.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.profileName.text = profile.name;
    self.profileLocation.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.profileLocation.text = profile.location;
    
    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];

    // If this is the currently logged in user, then hide the follow button
    VUser *me = [[VObjectManager sharedManager] mainUser];
    if (_profile == me)
    {
        self.followButton.hidden = YES;
    }
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setHaveRelationship:(BOOL)haveRelationship
{
    _haveRelationship = haveRelationship;
    
    if (_haveRelationship)
    {
        self.followButton.imageView.image = self.unfollowImage;
    }
    else
    {
        self.followButton.imageView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.followButton.imageView.image = self.followImage;
    }
}

- (IBAction)follow:(id)sender
{
    // Check for existance of follow block
    if (self.followButtonAction)
    {
        self.followButtonAction();
    }
    
    if ([VObjectManager sharedManager].authorized)
    {
        [self disableFollowIcon:nil];
    }
}

#pragma mark - Button Actions

- (void)flipFollowIconAction:(id)sender
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL relationship = [mainUser.following containsObject:self.profile];
    void (^animations)() = ^(void)
    {
        if (relationship)
        {
            [self.followButton setImage:self.unfollowImage forState:UIControlStateNormal];
        }
        else
        {
            [self.followButton setImage:self.followImage forState:UIControlStateNormal];
        }
        
        self.followButton.alpha = 1.0f;
        self.followButton.userInteractionEnabled = YES;
    };
    [UIView transitionWithView:self.followButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:animations
                    completion:^(BOOL finished)
     {
         [self enableFollowIcon:nil];
     }];
}

- (void)disableFollowIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followButton.alpha = 0.3f;
        self.followButton.userInteractionEnabled = NO;
    };
    
    [UIView transitionWithView:self.followButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
}

- (void)enableFollowIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followButton.alpha = 1.0f;
        self.followButton.userInteractionEnabled = YES;
    };
    
    [UIView transitionWithView:self.followButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
}

@end
