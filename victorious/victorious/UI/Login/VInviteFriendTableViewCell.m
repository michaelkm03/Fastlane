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
@property (nonatomic, weak)     IBOutlet    UIImageView*        followIcon;
@end

@implementation VInviteFriendTableViewCell

- (void)awakeFromNib
{
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
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
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
            self.followIcon.image = [UIImage imageNamed:@"buttonFollowed"];
        }
        else
        {
            self.followIcon.image = [UIImage imageNamed:@"buttonFollow"];
        }
    };
    if (animated)
    {
        [UIView transitionWithView:self.followIcon
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
