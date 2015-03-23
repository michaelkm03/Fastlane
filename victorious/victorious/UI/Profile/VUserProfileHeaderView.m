//
//  VUserProfileHeaderView.m
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileHeaderView.h"

#import "VUser+Fetcher.h"

#import "VDependencyManager.h"
#import "VObjectManager+Users.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"
#import "VSettingManager.h"
#import "VThemeManager.h"

#import <KVOController/FBKVOController.h>

static NSString * const kEditButtonStyleKey = @"editButtonStyle";
static NSString * const kEditButtonStylePill = @"rounded";

@interface VUserProfileHeaderView()

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonWidthConstraint;

@end

@implementation VUserProfileHeaderView

+ (instancetype)newView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VUserProfileHeaderView class]) owner:self options:nil];
    VUserProfileHeaderView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageView.layer.borderWidth = 2.0;

    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");

    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];

    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
}

- (void)setIsFollowingUser:(BOOL)isFollowingUser
{
    _isFollowingUser = isFollowingUser;
    
    [self applyEditProfileButtonStyle];
}

- (void)applyEditProfileButtonStyle
{
    if ( self.user == nil || self.dependencyManager == nil )
    {
        return;
    }
    
    const VUser *loggedInUser = [VObjectManager sharedManager].mainUser;
    const BOOL isCurrentUser = loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];

    UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    if ( linkColor == nil )
    {
        linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    UIFont *buttonFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    self.editProfileButton.titleLabel.font = buttonFont;

    if ( [[self.dependencyManager stringForKey:kEditButtonStyleKey] isEqualToString:kEditButtonStylePill] )
    {
        self.editProfileButton.cornerRadius = CGRectGetHeight(self.editProfileButton.bounds) / 2.0f;
    }
    
    // Set the text
    if ( isCurrentUser )
    {
        [self.editProfileButton setStyle:VButtonStyleSecondary];
        self.editProfileButton.primaryColor = linkColor;
        self.editProfileButton.secondaryColor = linkColor;
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
    
    CGSize size = [self.editProfileButton intrinsicContentSize];
    self.buttonWidthConstraint.constant = size.width;
    [self.editProfileButton layoutIfNeeded];
    [self layoutIfNeeded];
}

- (void)setUser:(VUser *)user
{
    if (_user == user)
    {
        [self applyEditProfileButtonStyle];
        return;
    }

    _user = user;
        
    if (_user == nil)
    {
        [self applyEditProfileButtonStyle];
        return;
    }
    
    [self applyEditProfileButtonStyle];
    
    [self cleanupKVOControllerWithUser:_user];
    [self setupKVOControllerWithUser:_user];
    
    [[VObjectManager sharedManager] countOfFollowsForUser:_user
                                             successBlock:nil
                                                failBlock:nil];
    
    __weak typeof(self) welf = self;
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
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    UIColor *linkColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    if ( linkColor == nil )
    {
        linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    }
    
    UIColor *accentColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    
    self.profileImageView.layer.borderColor = linkColor.CGColor;
    
    self.nameLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.nameLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    
    self.locationLabel.font = [_dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    
    self.taglineLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    self.taglineLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        
    self.followersLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followersLabel.textColor = accentColor;
    
    self.followersHeader.font = [_dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followersHeader.textColor = accentColor;

    self.followingLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    self.followingLabel.textColor = accentColor;

    self.followingHeader.font = [_dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    self.followingHeader.textColor = accentColor;

    UIColor *backgroundColor = [_dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.userStatsBar.backgroundColor = backgroundColor;
    [self applyEditProfileButtonStyle];
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
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowers];
    
    if ([self.delegate respondsToSelector:@selector(followerHandler)])
    {
        [self.delegate followerHandler];
    }
}

- (IBAction)pressedFollowering:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowing];
    
    if ([self.delegate respondsToSelector:@selector(followingHandler)])
    {
        [self.delegate followingHandler];
    }
}

#pragma mark - KVOController for properties of VUser

- (void)cleanupKVOControllerWithUser:(VUser *)user
{
    [self.KVOController unobserve:user];
}

- (void)setupKVOControllerWithUser:(VUser *)user
{
    __weak typeof(self) welf = self;
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(numberOfFollowers))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         welf.followersLabel.text = [welf.largeNumberFormatter stringForInteger:user.numberOfFollowers.integerValue];
     }];
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(numberOfFollowing))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         welf.followingLabel.text = [welf.largeNumberFormatter stringForInteger:user.numberOfFollowing.integerValue];
     }];
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(pictureUrl))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf.profileImageView setProfileImageURL:[NSURL URLWithString:user.pictureUrl]];
     }];
    
    [self.KVOController observe:user
                       keyPaths:@[ NSStringFromSelector(@selector(name)),
                                   NSStringFromSelector(@selector(tagline)),
                                   NSStringFromSelector(@selector(location)) ]
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf applyEditProfileButtonStyle];
         
         welf.nameLabel.text = user.name;
         welf.locationLabel.text = user.location;
         
         if ( user.tagline != nil && user.tagline.length > 0 )
         {
             welf.taglineLabel.text = user.tagline;
         }
         else
         {
             welf.taglineLabel.text = @"";
         }
     }];
}

@end
