//
//  VDiscoverSuggestedPersonCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverSuggestedPersonCell.h"
#import "VDefaultProfileButton.h"
#import "VFollowControl.h"
#import "VFollowersTextFormatter.h"
#import "VDependencyManager.h"
#import "VFollowResponder.h"
#import "victorious-Swift.h"
#import <KVOController/FBKVOController.h>

@interface VDiscoverSuggestedPersonCell()

@property (nonatomic, weak) IBOutlet VFollowControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileButton;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@end

@implementation VDiscoverSuggestedPersonCell

+ (CGFloat)cellHeight
{
    return 155.0f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat radius = self.profileButton.bounds.size.width * 0.5f;
    self.profileButton.layer.cornerRadius = radius;
    self.descriptionLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:9.0f];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followButton.dependencyManager = dependencyManager;
    if ( _dependencyManager != nil )
    {
        self.usernameLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.usernameLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.descriptionLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.followButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileButton.dependencyManager = dependencyManager;
        self.profileButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (void)setUser:(VUser *)user
{
    if (_user == user)
    {
        return;
    }
    
    [self.KVOController unobserve:_user
                          keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
    
    _user = user;
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:user
                       keyPaths:@[NSStringFromSelector(@selector(isFollowedByMainUser))]
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
    if ([_user isEqual:user])
    {
        return;
    }
    
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
    self.profileButton.user = self.user;
}

- (void)updateFollowingAnimated:(BOOL)animated
{
    // If this is the currently logged in user, then hide the follow button
    VUser *me = [VUser currentUser];
    self.followButton.hidden = (self.user == me);
    [self.followButton setControlState:[VFollowControl controlStateForFollowing:self.user.isFollowedByMainUser.boolValue] animated:animated];
    [self populateData];
}

- (IBAction)onFollow:(VFollowControl *)sender
{
    if ( sender.controlState == VFollowControlStateLoading )
    {
        return;
    }
    
    void (^authorizedBlock)() = ^
    {
        [sender setControlState:VFollowControlStateLoading animated:YES];
    };
    
    void (^completionBlock)(VUser *) = ^(VUser *userActedOn)
    {
        [self updateFollowingAnimated:YES];
    };
    
    if ( sender.controlState == VFollowControlStateFollowed )
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));

        [followResponder unfollowUser:self.user
                  withAuthorizedBlock:authorizedBlock
                        andCompletion:completionBlock
                   fromViewController:nil
                       withScreenName:nil];
    }
    else
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));        
        
        [followResponder followUser:self.user
                withAuthorizedBlock:authorizedBlock
                      andCompletion:completionBlock
                 fromViewController:nil
                     withScreenName:nil];
    }
}

@end
