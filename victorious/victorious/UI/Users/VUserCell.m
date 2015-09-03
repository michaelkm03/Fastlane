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
#import "VFollowControl.h"
#import "VDefaultProfileImageView.h"
#import "UIImageView+VLoadingAnimations.h"
#import <KVOController/FBKVOController.h>

static const CGFloat kUserCellHeight = 51.0f;

@interface VUserCell ()

@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet VFollowControl *followControl;
@property (nonatomic, strong) VUser *user;

@end

@implementation VUserCell

#pragma mark - VSharedCollectionReusableViewMethods

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
    self.contentView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public

- (void)setUser:(VUser *)user
{
    if ( [_user isEqual:user] )
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
    self.followControl.enabled = YES;
    
    [self updateFollowingAnimated:NO];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.userName.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.userImageView.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.followControl.dependencyManager = dependencyManager;
}

#pragma mark - Target/Action

- (IBAction)tappedFollowControl:(VFollowControl *)sender
{
    if ( sender.controlState == VFollowControlStateLoading )
    {
        return;
    }
    
    void (^authorizedBlock)() = ^
    {
        [sender setControlState:VFollowControlStateLoading
                       animated:YES];
    };
    
    void (^completionBlock)(VUser *) = ^(VUser *userActedOn)
    {
        [self updateFollowingAnimated:YES];
    };
    
    if (sender.controlState == VFollowControlStateFollowed)
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

- (void)updateFollowingAnimated:(BOOL)animated
{
    // If this is the currently logged in user, then hide the follow button
    VUser *me = [[VObjectManager sharedManager] mainUser];
    self.followControl.hidden = [self.user isEqual:me];
    VFollowControlState desiredControlState = [VFollowControl controlStateForFollowing:[me.following containsObject:self.user]];
    if ( self.followControl.controlState != desiredControlState )
    {
        [self.followControl setControlState:desiredControlState
                                   animated:animated];
    }
}

@end
