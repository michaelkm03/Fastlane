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
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.locationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    
    self.taglineLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.taglineLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    
    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];
    self.followersLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followersHeader.text = NSLocalizedString(@"followers", @"");
    self.followersHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    self.followingLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.followingHeader.text = NSLocalizedString(@"following", @"");
    self.followingHeader.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.editProfileButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.editProfileButton.titleLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.editProfileButton.layer.cornerRadius = 3.0;
    self.editProfileButton.layer.borderWidth = 2.0;
    
    self.followButtonActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.followButtonActivityIndicator.center = CGPointMake(CGRectGetWidth(self.editProfileButton.frame) / 2.0, CGRectGetHeight(self.editProfileButton.frame) / 2.0);
    [self.editProfileButton addSubview:self.followButtonActivityIndicator];
    
    [self.KVOController observe:self.editProfileButton
                        keyPath:@"selected"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                          block:^(id observer, UIButton *editProfileButton, NSDictionary *change)
     {
         if (editProfileButton.selected)
         {
             [editProfileButton setTitle:NSLocalizedString(@"following", @"") forState:UIControlStateNormal];
             editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
             editProfileButton.backgroundColor = [UIColor clearColor];
         }
         else
         {
             [editProfileButton setTitle:NSLocalizedString(@"follow", @"") forState:UIControlStateNormal];
             editProfileButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor].CGColor;
             editProfileButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
         }
     }];
}

- (void)setUser:(VUser *)user
{
    if (_user == user)
    {
        return;
    }
    
    [self.KVOController unobserveAll];
    _user = user;
    
    if (_user)
    {
        __weak typeof(self) welf = self;
        
        void (^userUpdateBlock)(id observer, VUser *user, NSDictionary *change) = ^void(id observer, VUser *user, NSDictionary *change)
        {
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
                welf.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
                welf.editProfileButton.backgroundColor = [UIColor clearColor];
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
                         welf.editProfileButton.selected = [resultObjects[0] boolValue];
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
                    welf.editProfileButton.selected = NO;
                }
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
