//
//  VInviteFriendTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteFriendTableViewCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VThemeManager.h"

@interface      VInviteFriendTableViewCell ()
@property (nonatomic, weak)     IBOutlet    UIImageView*        profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel*            profileName;
@property (nonatomic, weak)     IBOutlet    UILabel*            profileLocation;
@property (nonatomic, weak)     IBOutlet    UIButton*           followButton;
@end

@implementation VInviteFriendTableViewCell

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
    
    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    if (self.shouldInvite)
        [self.followButton setImage:[UIImage imageNamed:@"buttonFollowed"] forState:UIControlStateNormal];
    else
        [self.followButton setImage:[UIImage imageNamed:@"buttonFollow"] forState:UIControlStateNormal];
}

- (IBAction)follow:(id)sender
{
    if (self.shouldInvite)
    {
        [UIView transitionWithView:self.followButton
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        animations:^{
                            [self.followButton setImage:[UIImage imageNamed:@"buttonFollow"] forState:UIControlStateNormal];
                        } completion:nil];
        [self.delegate cellDidSelectUninvite:self];
    }
    else
    {
        [UIView transitionWithView:self.followButton
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        animations:^{
                            [self.followButton setImage:[UIImage imageNamed:@"buttonFollowed"] forState:UIControlStateNormal];
                        } completion:nil];
        [self.delegate cellDidSelectInvite:self];
    }

    self.shouldInvite = !self.shouldInvite;
}

@end
