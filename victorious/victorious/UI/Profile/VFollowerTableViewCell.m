//
//  VFollowerTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowerTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VThemeManager.h"

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

    self.followImage   = [UIImage imageNamed:@"buttonFollow"];
    self.unfollowImage = [UIImage imageNamed:@"buttonFollowed"];
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.profileImagePathSmall ?: profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
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
}

- (void)setHaveRelationship:(BOOL)haveRelationship
{
    _haveRelationship = haveRelationship;
    
    if (_haveRelationship)
    {
        self.followButton.hidden = YES;
    }
    else
    {
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
    
    [self disableFollowIcon:nil];
}

#pragma mark - Button Actions

- (void)enableFollowIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followButton.alpha = 1.0f;
        self.followButton.imageView.image = self.unfollowImage;
    };
    
    [UIView transitionWithView:self.followButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:animations
                    completion:nil];
}

- (void)flipFollowIconAction:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followButton.alpha = 1.0f;
        self.followButton.imageView.image = self.unfollowImage;
    };
    
    [UIView transitionWithView:self.followButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:animations
                    completion:nil];
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

@end
