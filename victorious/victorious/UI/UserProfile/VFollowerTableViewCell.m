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
@property (nonatomic, weak)     IBOutlet    UIImageView*        profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel*            profileName;
@property (nonatomic, weak)     IBOutlet    UILabel*            profileLocation;
@property (nonatomic, weak)     IBOutlet    UIButton*           followButton;
@property (nonatomic)                       BOOL                following;
@end

@implementation VFollowerTableViewCell

- (void)setProfile:(VUser *)profile
{
    _profile = profile;

    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileImage.layer.cornerRadius = CGRectGetHeight(self.profileImage.bounds)/2;
    self.profileImage.layer.borderWidth = 1.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
    
    self.profileName.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.profileName.text = profile.name;
    self.profileLocation.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.profileLocation.text = profile.location;
    
    self.followButton.hidden = !self.showButton;
    
    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
//  self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryBackgroundColor];
}

- (IBAction)follow:(id)sender
{
    if (self.following)
    {
        self.following = NO;
        [[VObjectManager sharedManager] unfollowUser:self.profile successBlock:nil failBlock:nil];
//      [UIView animateWithDuration:0.4 animations:^{
//        [self.followButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//      }];
    }
    else
    {
        self.following = YES;
        [[VObjectManager sharedManager] followUser:self.profile successBlock:nil failBlock:nil];
//      [UIView animateWithDuration:0.4 animations:^{
//        [self.followButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//      }];
    }
}

@end
