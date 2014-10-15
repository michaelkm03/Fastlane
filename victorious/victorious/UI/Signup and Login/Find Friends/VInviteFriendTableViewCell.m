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
#import "VObjectManager+Login.h"

NSString * const VInviteFriendTableViewCellNibName = @"VInviteFriendTableViewCell";

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak)     IBOutlet    UIImageView        *profileImage;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileName;
@property (nonatomic, weak)     IBOutlet    UILabel            *profileLocation;
@property (nonatomic, weak)     IBOutlet    NSLayoutConstraint *userInfoWidthConstraint;
@property (nonatomic, weak)     IBOutlet    UIView             *labelsSuperview;
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
    
    // Constraint to lock user info in place even when the view changes
    self.userInfoWidthConstraint = [NSLayoutConstraint constraintWithItem:self.labelsSuperview
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.profileName
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0f
                                                                 constant:10.0f];
    [self addConstraint:self.userInfoWidthConstraint];
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileName.text = profile.name;
    self.profileLocation.text = profile.location;
}

- (void)setHaveRelationship:(BOOL)haveRelationship
{
    _haveRelationship = haveRelationship;
    
    if (_haveRelationship)
    {
        self.followIconImageView.image = self.unfollowIcon;
    }
    else
    {
        self.followIconImageView.image = self.followIcon;
    }
}

- (void)imageTapAction:(id)sender
{
    // Check for existance of follow block
    if (self.followAction)
    {
        self.followAction();
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
            self.followIconImageView.image = self.unfollowIcon;
        }
        else
        {
            [self.followIconImageView setImage:self.followIcon];
        }
    };
    [UIView transitionWithView:self.followIconImageView
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
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL relationship = [mainUser.following containsObject:self.profile];
    void (^animations)() = ^(void)
    {
        if (relationship)
        {
            [self.followIconImageView setImage:self.unfollowIcon];

        }
        else
        {
            [self.followIconImageView setImage:self.followIcon];
        }
        
        self.followIconImageView.alpha = 0.3f;
        self.followIconImageView.userInteractionEnabled = NO;
    };
    [UIView transitionWithView:self.followIconImageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
    
}

- (void)enableFollowIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followIconImageView.alpha = 1.0f;
        self.followIconImageView.userInteractionEnabled = YES;
    };
    
    [UIView transitionWithView:self.followIconImageView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
}

@end
