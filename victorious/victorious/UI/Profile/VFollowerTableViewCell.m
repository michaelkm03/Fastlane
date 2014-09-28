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

@end

@implementation VFollowerTableViewCell

- (void)setProfile:(VUser *)profile
{
    _profile = profile;

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
    
    UIImage *image = [UIImage imageNamed:@"buttonFollow"];
    
    if (_haveRelationship)
    {
        image = [UIImage imageNamed:@"buttonFollowed"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.followButton setImage:image forState:UIControlStateNormal];
    });
}

- (IBAction)follow:(id)sender
{
    UIImage *followImage = [UIImage imageNamed:@"buttonFollow"];
    UIImage *followedImage = [UIImage imageNamed:@"buttonFollowed"];
    
    // Check for existance of follow block
    if (self.followButtonAction)
    {
        self.followButtonAction();
    }
    
    void (^animations)() = ^(void)
    {
        if (_haveRelationship)
        {
            [self.followButton setImage:followImage forState:UIControlStateNormal];
        }
        else
        {
            [self.followButton  setImage:followedImage forState:UIControlStateNormal];
        }
    };
    
    [UIView transitionWithView:self.followButton
                          duration:0.3
                           options:(_haveRelationship ? UIViewAnimationOptionTransitionFlipFromTop : UIViewAnimationOptionTransitionFlipFromBottom)
                        animations:animations
                        completion:nil];
}

@end
