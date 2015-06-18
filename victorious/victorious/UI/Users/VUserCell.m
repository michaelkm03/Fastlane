//
//  VUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserCell.h"
#import "VFollowResponder.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VDependencyManager.h"
#import "VDefaultProfileButton.h"
#import "VFollowUserControl.h"
#import "VDefaultProfileImageView.h"
#import "UIImageView+VLoadingAnimations.h"
#import <KVOController/FBKVOController.h>

static const CGFloat kUserCellHeight = 51.0f;

@interface VUserCell ()

@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UILabel *userLocation;
@property (nonatomic, weak) IBOutlet VFollowUserControl *followControl;
@property (nonatomic, strong) VUser *user;

@end

@implementation VUserCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass(self);
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake( CGRectGetWidth(bounds), kUserCellHeight );
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.userImageView.layer.cornerRadius = CGRectGetWidth(self.userImageView.bounds) / 2;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.borderWidth = 1.0;
    self.userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.97
                                                         alpha:1.0];
}

#pragma mark - Public

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
    
    [self.userImageView setProfileImageURL:[NSURL URLWithString:user.pictureUrl]];
    self.userName.text = user.name;
    self.userLocation.text = user.location;
    self.followControl.enabled = YES;
    
    [self updateFollowingAnimated:NO];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.userName.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.userLocation.font = [_dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.followControl.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.userImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

#pragma mark - Target/Action

- (IBAction)tappedFollowControl:(VFollowUserControl *)sender
{
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withCompletion:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"VUserCell needs a VFollowingResponder higher up the chain to communicate following commands with.");
    sender.enabled = NO;
    if (sender.following)
    {
        [followResponder unfollowUser:self.user withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
    else
    {
        [followResponder followUser:self.user withCompletion:^(VUser *userActedOn)
         {
             sender.enabled = YES;
         }];
    }
}

#pragma mark - Private Methods

- (void)updateFollowingAnimated:(BOOL)animated
{
    // If this is the currently logged in user, then hide the follow button
    VUser *me = [[VObjectManager sharedManager] mainUser];
    self.followControl.hidden = (self.user == me);
    [self.followControl setFollowing:[me.following containsObject:self.user]
                            animated:animated];
}

@end
