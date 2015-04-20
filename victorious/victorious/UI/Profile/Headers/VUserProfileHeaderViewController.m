//
//  VUserProfileHeaderViewController.m
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileHeaderViewController.h"
#import "VUser+Fetcher.h"
#import "VDependencyManager.h"
#import "VObjectManager+Users.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"
#import "VSettingManager.h"
#import "VThemeManager.h"
#import "VDependencyManager+VUserProfile.h"

#import <KVOController/FBKVOController.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface VUserProfileHeaderViewController()

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VUserProfileHeaderViewController

@synthesize delegate;
@synthesize isFollowingUser = _isFollowingUser;
@synthesize user = _user;
@synthesize preferredHeight;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self applyProfileImageViewStyle];

    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");

    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];

    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    
    [self updatePrimaryActionButton];
    [self applyStyleWithDependencyManager:self.dependencyManager];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    [self updatePrimaryActionButton];
    
    self.user = [self.dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManagerUserKey];
}

- (void)loadBackgroundImage:(NSURL *)imageURL
{
    [self.backgroundImageView sd_setImageWithURL:imageURL placeholderImage:nil completed:nil];
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setImage:nil];
}

- (void)updatePrimaryActionButton
{
    if ( self.user == nil || self.dependencyManager == nil )
    {
        return;
    }
    
    [self applyAllStatesEditButtonStyle];
    
    
    if ( self.isCurrentUser )
    {
        [self applyCurrentUserStyle];
    }
    else
    {
        if ( self.isFollowingUser )
        {
            [self applyFollowingStyle];
        }
        else
        {
            [self applyNotFollowingStyle];
        }
    }
}

- (BOOL)isCurrentUser
{
    const VUser *loggedInUser = [VObjectManager sharedManager].mainUser;
    return loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];
}

- (void)applyProfileImageViewStyle
{
}

#pragma mark - Edit profile button

- (void)applyCurrentUserStyle
{
    NSAssert( NO, @"`applyCurrentUserStyle` method must be implemented in a subclass of `VUserProfileHeaderViewController`." );
}

- (void)applyFollowingStyle
{
    NSAssert( NO, @"`applyFollowingStyle` method must be implemented in a subclass of `VUserProfileHeaderViewController`." );
}

- (void)applyNotFollowingStyle
{
    NSAssert( NO, @"`applyNotFollowingStyle` method must be implemented in a subclass of `VUserProfileHeaderViewController`." );
}

- (void)applyAllStatesEditButtonStyle
{
    // This method is optional
}

#pragma mark - Setters

- (void)setIsLoading:(BOOL)isLoading
{
    if ( isLoading )
    {
        self.primaryActionButton.enabled = NO;
    }
    else
    {
        self.primaryActionButton.enabled = YES;
    }
}

- (void)setIsFollowingUser:(BOOL)isFollowingUser
{
    _isFollowingUser = isFollowingUser;
    [self updatePrimaryActionButton];
}

- (void)setUser:(VUser *)user
{
    _user = user;
        
    [self clearBackgroundImage];
    [self loadBackgroundImage:[NSURL URLWithString:self.user.pictureUrl]];
    
    [self reload];
}

- (void)reload
{
    [self updatePrimaryActionButton];
    
    if ( _user != nil )
    {
        [self cleanupKVOControllerWithUser:_user];
    }
    
    if ( self.user == nil )
    {
        [self updatePrimaryActionButton];
        return;
    }
    
    [self updatePrimaryActionButton];
    [self setupKVOControllerWithUser:_user];
    
    [[VObjectManager sharedManager] countOfFollowsForUser:_user
                                             successBlock:nil
                                                failBlock:nil];
    
    const BOOL isCurrentUser = [self.user.remoteId isEqualToNumber:[VObjectManager sharedManager].mainUser.remoteId];
    if ( isCurrentUser )
    {
        [self applyCurrentUserStyle];
    }
    else
    {
        __weak typeof(self) welf = self;
        if ([VObjectManager sharedManager].mainUser)
        {
            welf.primaryActionButton.alpha = 0.0f;
            [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                         following:self.user
                                      successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
             {
                 welf.isFollowingUser = [resultObjects.firstObject boolValue];
                 [UIView animateWithDuration:0.2f
                                  animations:^
                  {
                      welf.primaryActionButton.alpha = 1.0f;
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

- (void)setFollowersCount:(NSNumber *)followerCount
{
    if ( followerCount != nil )
    {
        self.followersButton.hidden = NO;
        self.followersHeader.hidden = NO;
        self.followersLabel.hidden = NO;
        self.followersLabel.text = [self.largeNumberFormatter stringForInteger:followerCount.integerValue];
    }
    else
    {
        self.followersButton.hidden = YES;
        self.followersHeader.hidden = YES;
        self.followersLabel.hidden = YES;
    }
}

- (void)setFollowingCount:(NSNumber *)followingCount
{
    if ( followingCount != nil )
    {
        self.followingButton.hidden = NO;
        self.followingHeader.hidden = NO;
        self.followingLabel.hidden = NO;
        self.followingLabel.text = [self.largeNumberFormatter stringForInteger:followingCount.integerValue];
    }
    else
    {
        self.followingButton.hidden = YES;
        self.followingHeader.hidden = YES;
        self.followingLabel.hidden = YES;
    }
}

- (void)applyStyleWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert( NO, @"`applyStyleWithDependencyManager:` method must be implemented in a subclass of `VUserProfileHeaderViewController`." );
}

#pragma mark - Actions

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
         [welf setFollowersCount:user.numberOfFollowers];
     }];
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(numberOfFollowing))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf setFollowingCount:user.numberOfFollowing];
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
         [welf reloadObservedProfileProperties];
     }];
}

- (void)reloadObservedProfileProperties
{
    [self updatePrimaryActionButton];
    
    self.nameLabel.text = self.user.name != nil ? self.user.name : @"";
    self.locationLabel.text = self.user.location;
    
    if ( self.user.tagline != nil && self.user.tagline.length > 0 )
    {
        self.taglineLabel.text = self.user.tagline;
    }
    else
    {
        self.taglineLabel.text = @"";
    }
}

@end
