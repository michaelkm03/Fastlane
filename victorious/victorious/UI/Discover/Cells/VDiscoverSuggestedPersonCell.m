//
//  VDiscoverSuggestedPersonCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDiscoverSuggestedPersonCell.h"
#import "VDefaultProfileImageView.h"
#import "VFollowUserControl.h"
#import "VFollowersTextFormatter.h"
#import "VObjectManager+Users.h"
#import "VDependencyManager.h"
#import "VFollowResponder.h"
#import <KVOController/FBKVOController.h>
#import "VAuthorizedAction.h"

@interface VDiscoverSuggestedPersonCell()

@property (nonatomic, weak) IBOutlet VFollowUserControl *followButton;
@property (nonatomic, weak) IBOutlet VDefaultProfileImageView *profileImageView;
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
    
    CGFloat radius = self.profileImageView.bounds.size.width * 0.5f;
    self.profileImageView.layer.cornerRadius = radius;
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
    [self.followButton setFollowingUser:self.user.isFollowedByMainUser.boolValue animated:animated];
}

- (IBAction)onFollow:(VFollowUserControl *)sender
{
    void (^followAction)() = ^void()
    {
        id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                          withSender:nil];
        NSAssert(followResponder != nil, @"VFollowerTableViewCell needs a VFollowingResponder higher up the chain to communicate following commands with.");
        sender.enabled = NO;
        if (sender.following)
        {
            [followResponder unfollowUser:self.user
                           withCompletion:^(VUser *userActedOn)
             {
                 sender.enabled = YES;
             }];
        }
        else
        {
            [followResponder followUser:self.user
                         withCompletion:^(VUser *userActedOn)
             {
                 sender.enabled = YES;
             }];
        }
    };
    
    VAuthorizedAction *authorizedAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                         dependencyManager:self.dependencyManager];
    UIViewController *nearestViewController = [self targetForAction:@selector(presentViewController:animated:completion:) withSender:self];
    [authorizedAction performFromViewController:nearestViewController
                                         context:VAuthorizationContextFollowUser
                                      completion:^(BOOL authorized)
    {
        if (authorized)
        {
            followAction();
        }
        else
        {
            sender.enabled = YES;
        }
    }];
}

@end
