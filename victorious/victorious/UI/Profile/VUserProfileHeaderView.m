//
//  VUserProfileHeaderView.m
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileHeaderView.h"

#import "VUser.h"

#import "VThemeManager.h"
#import "VObjectManager+Users.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"
#import "VSettingManager.h"

#import <KVOController/FBKVOController.h>

@implementation VUserProfileHeaderView

+ (instancetype)newViewWithFrame:(CGRect)frame
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VUserProfileHeaderView class]) owner:self options:nil];
    VUserProfileHeaderView *view = [nibViews objectAtIndex:0];
    view.frame = frame;
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];
    self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");
    self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.userStatsBar.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    [self applyEditProfileButtonStyle];
}

- (void)setIsFollowingUser:(BOOL)isFollowingUser
{
    _isFollowingUser = isFollowingUser;
    
    [self applyEditProfileButtonStyle];
}

- (void)applyEditProfileButtonStyle
{
    if ( self.user == nil )
    {
        return;
    }
    
    const VUser *loggedInUser = [VObjectManager sharedManager].mainUser;
    const BOOL isCurrentUser = loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];

    UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];

    // Set the text
    if ( isCurrentUser )
    {
        [self.editProfileButton setStyle:VButtonStyleSecondary];
        self.editProfileButton.primaryColor = linkColor;
        self.editProfileButton.secondaryColor = [UIColor blackColor];
        [self.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
    }
    else
    {
        if ( self.isFollowingUser )
        {
            [self.editProfileButton setStyle:VButtonStyleSecondary];
            self.editProfileButton.primaryColor = linkColor;
            self.editProfileButton.secondaryColor = linkColor;
            [self.editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
        }
        else
        {
            [self.editProfileButton setStyle:VButtonStylePrimary];
            self.editProfileButton.primaryColor = linkColor;
            self.editProfileButton.secondaryColor = linkColor;
            [self.editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
        }
    }
}

- (void)setUser:(VUser *)user
{
    if (_user == user)
    {
        [self applyEditProfileButtonStyle];
        return;
    }
    
    [self.KVOController unobserve:_user];

    _user = user;
    
    if (_user == nil)
    {
        [self applyEditProfileButtonStyle];
        return;
    }
    
    [self applyEditProfileButtonStyle];
    
    __weak typeof(self) welf = self;
    
    [[VObjectManager sharedManager] countOfFollowsForUser:user
                                             successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         welf.numberOfFollowers = [resultObjects[0] integerValue];
         welf.numberOfFollowing = [resultObjects[1] integerValue];
     }
                                                failBlock:^(NSOperation *operation, NSError *error)
     {
         welf.numberOfFollowers = 0;
         welf.numberOfFollowing = 0;
     }];
    
    if (user.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue)
    {
        [welf.editProfileButton setTitle:NSLocalizedString(@"editProfileButton", @"") forState:UIControlStateNormal];
    }
    else
    {
        if ([VObjectManager sharedManager].mainUser)
        {
            welf.editProfileButton.alpha = 0.0f;
            [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                         following:user
                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 welf.isFollowingUser = [resultObjects[0] boolValue];
                 [UIView animateWithDuration:0.2f
                                  animations:^
                  {
                      welf.editProfileButton.alpha = 1.0f;
                  }];
             }
                                         failBlock:nil];
        }
        else
        {
            welf.isFollowingUser = NO;
        }
    }
    
    void (^userUpdateBlock)(id observer, VUser *user, NSDictionary *change) = ^void(id observer, VUser *user, NSDictionary *change)
    {
        [welf applyEditProfileButtonStyle];
        
        [welf.profileImageView setProfileImageURL:[NSURL URLWithString:user.pictureUrl]];
        welf.nameLabel.text = user.name;
        welf.locationLabel.text = user.location;
        
        if (user.tagline && user.tagline.length)
        {
            welf.taglineLabel.text = user.tagline;
        }
        else
        {
            welf.taglineLabel.text = @"";
        }
    };
    
    [self.KVOController observe:user
                       keyPaths:@[NSStringFromSelector(@selector(name)),
                                  NSStringFromSelector(@selector(pictureUrl)),
                                  NSStringFromSelector(@selector(tagline)),
                                  NSStringFromSelector(@selector(location))]
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:userUpdateBlock];
}

- (void)setNumberOfFollowers:(NSInteger)numberOfFollowers
{
    _numberOfFollowers = numberOfFollowers;
    self.followersLabel.text = [[[VLargeNumberFormatter alloc] init] stringForInteger:numberOfFollowers];
}

- (void)setNumberOfFollowing:(NSInteger)numberOfFollowing
{
    _numberOfFollowing = numberOfFollowing;
    self.followingLabel.text = [[[VLargeNumberFormatter alloc] init] stringForInteger:numberOfFollowing];
}

- (IBAction)pressedEditProfile:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(editProfileHandler)])
    {
        [self.delegate editProfileHandler];
    }
}

- (IBAction)pressedFollowers:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followerHandler)])
    {
        [self.delegate followerHandler];
    }
}

- (IBAction)pressedFollowering:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(followingHandler)])
    {
        [self.delegate followingHandler];
    }
}

@end
