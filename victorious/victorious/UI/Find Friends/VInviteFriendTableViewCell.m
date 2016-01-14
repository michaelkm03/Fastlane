//
//  VInviteFriendTableViewCell.m
//  victorious
//
//  Created by Gary Philipp on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteFriendTableViewCell.h"
#import "VUser.h"
#import "VFollowControl.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VDependencyManager.h"
#import "VDefaultProfileButton.h"
#import "victorious-Swift.h"
#import <KVOController/FBKVOController.h>

static const CGFloat kInviteCellHeight = 50.0f;

@interface VInviteFriendTableViewCell ()

@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileButton;
@property (nonatomic, weak) IBOutlet UILabel *profileName;
@property (nonatomic, weak) IBOutlet UIView *labelsSuperview;
@property (nonatomic, strong) UIImage *followIcon;
@property (nonatomic, strong) UIImage *unfollowIcon;

@end

@implementation VInviteFriendTableViewCell

- (void)awakeFromNib
{
    [self.profileButton addBorderWithWidth:1.0f andColor:[UIColor whiteColor]];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    if ([AgeGate isAnonymousUser])
    {
        [self.followUserControl removeFromSuperview];
        self.followUserControl = nil;
    }
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

- (void)setProfile:(VUser *)profile
{
    
    [self.KVOController unobserve:_profile
                          keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
    
    _profile = profile;
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:profile
                        keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateFollowStatusAnimated:YES];
     }];
    
    self.profileButton.user = profile;
    self.profileName.text = profile.name;
    
    NSInteger profileID = profile.remoteId.integerValue;
    NSInteger mainUserID = [VCurrentUser user].remoteId.integerValue;
    self.followUserControl.hidden = (profileID == mainUserID);
    
    [self updateFollowStatusAnimated:NO];
}

- (void)updateFollowStatusAnimated:(BOOL)animated
{
    VFollowControlState controlState = [VFollowControl controlStateForFollowing:self.profile.isFollowedByMainUser.boolValue];
    [self.followUserControl setControlState:controlState animated:animated];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.followUserControl.dependencyManager = dependencyManager;
        self.profileButton.dependencyManager = dependencyManager;
        self.profileButton.tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileName.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    }
}

#pragma mark - Button Actions

- (IBAction)followUnfollowUser:(VFollowControl *)sender
{
    long long userId = self.profile.remoteId.longLongValue;
    NSString *screenName = @"";
    
    RequestOperation *operation;
    if ( self.profile.isFollowedByMainUser.boolValue )
    {
        operation = [[UnfollowUserOperation alloc] initWithUserID:userId screenName:screenName];
    }
    else
    {
        operation = [[FollowUserOperation alloc] initWithUserID:userId screenName:screenName];
    }
    
    [operation queueOn:[RequestOperation sharedQueue] completionBlock:nil];
}

@end
