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
#import "VFollowControl.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const CGFloat kInviteCellHeight = 50.0f;

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *profileName;
@property (nonatomic, weak) IBOutlet UIView *labelsSuperview;
@property (nonatomic, strong) UIImage *followIcon;
@property (nonatomic, strong) UIImage *unfollowIcon;

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
    self.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass(self);
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kInviteCellHeight);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.shouldAnimateFollowing = NO;
}

- (void)setProfile:(VUser *)profile
{
    _profile = profile;
    
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:profile.pictureUrl]
                         placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
    self.profileName.text = profile.name;
    
    NSInteger profileID = profile.remoteId.integerValue;
    NSInteger mainUserID = [VObjectManager sharedManager].mainUser.remoteId.integerValue;
    self.followUserControl.hidden = (profileID == mainUserID);
    
    [self updateFollowStatus];
}

- (BOOL)haveRelationship
{
    BOOL relationship = self.profile.isFollowedByMainUser.boolValue;
    return relationship;
}

- (void)updateFollowStatus
{
    //If we get into a weird state and the relaionships are the same don't do anything
    
    if (self.followUserControl.controlState == [VFollowControl controlStateForFollowing:self.haveRelationship])
    {
        return;
    }
    if (!self.shouldAnimateFollowing)
    {
        self.followUserControl.controlState = [VFollowControl controlStateForFollowing:self.haveRelationship];
        return;
    }
    
    [self.followUserControl setControlState:[VFollowControl controlStateForFollowing:self.haveRelationship]
                                   animated:YES];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followUserControl.dependencyManager = dependencyManager;
}

#pragma mark - Button Actions

- (IBAction)followUnfollowUser:(id)sender
{
    self.shouldAnimateFollowing = YES;
    
    if (self.followAction != nil)
    {
        self.followAction();
    }
}

@end
