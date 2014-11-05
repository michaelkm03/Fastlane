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
#import "VFollowUserControl.h"

NSString * const VInviteFriendTableViewCellNibName = @"VInviteFriendTableViewCell";

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *profileName;
@property (nonatomic, weak) IBOutlet UILabel *profileLocation;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *userInfoWidthConstraint;
@property (nonatomic, weak) IBOutlet UIView *labelsSuperview;
@property (nonatomic, strong) UIImage *followIcon;
@property (nonatomic, strong) UIImage *unfollowIcon;
@property (nonatomic, assign) BOOL shouldAnimateFollowing;

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

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.shouldAnimateFollowing = NO;
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self.profileImage setImageWithURL:[NSURL URLWithString:profile.pictureUrl] placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileName.text = profile.name;
    self.profileLocation.text = profile.location;
    
    NSInteger profileID = _profile.remoteId.integerValue;
    NSInteger mainUserID = [VObjectManager sharedManager].mainUser.remoteId.integerValue;
    self.followUserControl.hidden = (profileID == mainUserID);
    
    [self updateFollowStatus];
}

- (BOOL)haveRelationship
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL relationship = [mainUser.following containsObject:self.profile];
    return relationship;
}

- (void)updateFollowStatus
{
    if (!self.shouldAnimateFollowing)
    {
        self.followUserControl.following = self.haveRelationship;
        return;
    }
    
    [self.followUserControl setFollowing:self.haveRelationship
                                animated:YES];
}

#pragma mark - Button Actions

- (IBAction)followUnfollowUser:(id)sender
{
    self.shouldAnimateFollowing = YES;
    if (self.followAction)
    {
        self.followAction();
    }
}

@end
