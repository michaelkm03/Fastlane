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
    
    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];

    self.followButton.hidden = YES;
    if (self.showButton)
    {
        [[VObjectManager sharedManager] isUser:self.owner
                                     following:self.profile
                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
         {
             if (![resultObjects[0] boolValue])
                 self.followButton.hidden = NO;
         }
                                     failBlock:nil];
    }
}

- (IBAction)follow:(id)sender
{
    [[VObjectManager sharedManager] followUser:self.profile successBlock:nil failBlock:nil];
    
    [UIView transitionWithView:self.followButton
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        [self.followButton setImage:[UIImage imageNamed:@"buttonFollowed"] forState:UIControlStateNormal];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:1.0 animations:^{
                            self.followButton.alpha = 0.0;
                        }
                                         completion:^(BOOL finished)
                         {
                             self.followButton.hidden = YES;
                         }];
                    }];
}

@end
