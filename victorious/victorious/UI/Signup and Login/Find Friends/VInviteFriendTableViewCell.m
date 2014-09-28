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
#import "VObjectManager.h"

NSString * const VInviteFriendTableViewCellNibName = @"VInviteFriendTableViewCell";

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak)     IBOutlet    UIImageView        *profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileName;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileLocation;
@property (nonatomic, strong)               UIImage            *followIcon;
@property (nonatomic, strong)               UIImage            *unfollowIcon;

@end

@implementation VInviteFriendTableViewCell

- (void)awakeFromNib
{
    self.followIcon   = [UIImage imageNamed:@"buttonFollow"];
    self.unfollowIcon = [UIImage imageNamed:@"buttonFollowed"];
    self.followIconImageView.image = self.unfollowIcon;
    [self.followIconImageView setUserInteractionEnabled:YES];
    
    self.profileImage.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.profileImage.layer.cornerRadius = CGRectGetHeight(self.profileImage.bounds)/2;
    self.profileImage.layer.borderWidth = 1.0;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.clipsToBounds = YES;
    
    self.profileName.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.profileLocation.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    
    // Add gesture to follow/unfollow imageview
    UITapGestureRecognizer *actionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapAction:)];
    actionTap.numberOfTapsRequired = 1;
    [self.followIconImageView addGestureRecognizer:actionTap];
}

- (void)setHaveRelationship:(BOOL)haveRelationship
{
    _haveRelationship = haveRelationship;
    
    UIImage *image = [UIImage imageNamed:@"buttonFollow"];
    
    if (_haveRelationship)
    {
        image = [UIImage imageNamed:@"buttonFollowed"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.followIconImageView setImage:image];
    });
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.profileImagePathSmall ?: profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileName.text = profile.name;
    self.profileLocation.text = profile.location;
    
    UIImage *buttonImage;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    
    BOOL followingOrFollower = ([_profile.followers containsObject:mainUser] || [_profile.following containsObject:mainUser]);
    if (followingOrFollower)
    {
        buttonImage = self.unfollowIcon;
    }
    else
    {
        buttonImage = self.followIcon;
    }
    
     dispatch_async(dispatch_get_main_queue(), ^(void)
    {
         self.followIconImageView.image = buttonImage;
     });
}

- (void)imageTapAction:(id)sender
{
    UIImage *followImage = [UIImage imageNamed:@"buttonFollow"];
    UIImage *followedImage = [UIImage imageNamed:@"buttonFollowed"];
    
    // Check for existance of follow block
    if (self.followAction)
    {
        self.followAction();
    }
    
    void (^animations)() = ^(void)
    {
        if (_haveRelationship)
        {
            [self.followIconImageView setImage:followImage];
        }
        else
        {
            [self.followIconImageView  setImage:followedImage];
        }
    };
    
    [UIView transitionWithView:self.followIconImageView
                      duration:0.3
                       options:(_haveRelationship ? UIViewAnimationOptionTransitionFlipFromTop : UIViewAnimationOptionTransitionFlipFromBottom)
                    animations:animations
                    completion:nil];
}

@end
