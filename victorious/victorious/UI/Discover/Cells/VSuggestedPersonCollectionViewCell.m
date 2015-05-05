//
//  VSuggestedPersonCollectionViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSuggestedPersonCollectionViewCell.h"
#import "VThemeManager.h"
#import "VDefaultProfileImageView.h"
#import "VFollowUserControl.h"
#import "VFollowersTextFormatter.h"
#import "VObjectManager+Users.h"
#import "VDependencyManager.h"
#import "VFollowing.h"
#import <KVOController/FBKVOController.h>

@interface VSuggestedPersonCollectionViewCell()

@property (nonatomic, weak) IBOutlet VFollowUserControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end

@implementation VSuggestedPersonCollectionViewCell

+ (UIImage *)followedImage
{
    static UIImage *followedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followedImage = [UIImage imageNamed:@"folllowedIcon"];
                  });
    return followedImage;
}

+ (UIImage *)followImage
{
    static UIImage *followImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      followImage = [UIImage imageNamed:@"folllowIcon"];
                  });
    return followImage;
}

+ (CGFloat)cellHeight
{
    return 155.0f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat radius = self.profileImageView.bounds.size.width * 0.5f;
    self.profileImageView.layer.cornerRadius = radius;
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( _dependencyManager != nil )
    {
        self.usernameLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.usernameLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.descriptionLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.followButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (void)setUser:(VUser *)user
{
    if (_user == user)
    {
        return;
    }
    
    [self.KVOController unobserve:_user
                          keyPath:NSStringFromSelector(@selector(followers))];
    
    _user = user;
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:user
                       keyPaths:@[NSStringFromSelector(@selector(followers))]
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateFollowingAnimated:YES];
     }];
    
    self.followButton.enabled = YES;
    
    [self populateData];
    [self updateFollowingAnimated:NO];
}


- (void)setUser:(VUser *)user
       animated:(BOOL)animated
{
    if (!animated)
    {
        self.user = user;
        return;
    }
    self.user = user;
    [self populateData];
    [self updateFollowingAnimated:animated];
}

- (void)populateData
{
    NSInteger intValue = self.user.numberOfFollowers.integerValue;
    self.descriptionLabel.text = [VFollowersTextFormatter followerTextWithNumberOfFollowers:intValue];
    
    self.usernameLabel.text = self.user.name;
    
    if ( self.user.pictureUrl != nil )
    {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:self.user.pictureUrl]];
    }
}

- (void)updateFollowingAnimated:(BOOL)animated
{
    // If this is the currently logged in user, then hide the follow button
    VUser *me = [[VObjectManager sharedManager] mainUser];
    self.followButton.hidden = (self.user == me);
    [self.followButton setFollowing:[me.following containsObject:self.user]
                           animated:animated];
}

- (IBAction)onFollow:(VFollowUserControl *)sender
{
    id<VFollowing> followCommandHandler = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                     withSender:nil];
    NSAssert(followCommandHandler != nil, @"VFollowerTableViewCell needs a VFollowingResponder higher up the chain to communicate following commands with.");
    sender.enabled = NO;
    if (sender.following)
    {
        [followCommandHandler unfollowUser:self.user
                            withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
    else
    {
        [followCommandHandler followUser:self.user
                          withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
}

@end
