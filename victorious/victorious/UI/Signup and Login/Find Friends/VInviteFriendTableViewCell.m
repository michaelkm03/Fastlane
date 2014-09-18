//
//  VInviteFriendTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteFriendTableViewCell.h"
#import "VUser.h"
#import "VThemeManager.h"

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak)     IBOutlet    UIImageView        *profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileName;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileLocation;
@property (nonatomic, weak)     IBOutlet    UIImageView        *followIconImageView;
@property (nonatomic, strong)               UIImage            *followIcon;
@property (nonatomic, strong)               UIImage            *unfollowIcon;

@end

@implementation VInviteFriendTableViewCell

- (void)awakeFromNib
{
    self.followIcon   = [UIImage imageNamed:@"buttonFollow"];
    self.unfollowIcon = [UIImage imageNamed:@"buttonFollowed"];
    self.followIconImageView.image = self.followIcon;
    
    self.profileImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileImage.layer.cornerRadius = CGRectGetHeight(self.profileImage.bounds)/2;
    self.profileImage.layer.borderWidth = 1.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
    
    self.profileName.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.profileLocation.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.profileImagePathSmall ?: profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileName.text = profile.name;
    self.profileLocation.text = profile.location;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    [super setSelected:selected animated:animated];
    
    void (^animations)() = ^(void)
    {
        if (selected)
        {
            self.followIconImageView.image = self.unfollowIcon;
        }
        else
        {
            self.followIconImageView.image = self.followIcon;
        }
    };
    if (animated)
    {
        [UIView transitionWithView:self.followIconImageView
                          duration:0.3
                           options:(selected ? UIViewAnimationOptionTransitionFlipFromTop : UIViewAnimationOptionTransitionFlipFromBottom)
                        animations:animations
                        completion:nil];
    }
    else
    {
        animations();
    }
}

@end
