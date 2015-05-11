//
//  VUserProfileHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserProfileHeaderViewController.h"
#import "VUser+Fetcher.h"
#import "VDependencyManager.h"
#import "VLargeNumberFormatter.h"
#import "VDefaultProfileImageView.h"
#import "VDependencyManager+VUserProfile.h"
#import "VDependencyManager+VBackgroundContainer.h"

#import <KVOController/FBKVOController.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface VUserProfileHeaderViewController() <VBackgroundContainer>

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VUserProfileHeaderViewController

@synthesize user = _user;
@synthesize state = _state;
@synthesize loading = _isLoading;
@synthesize preferredHeight = _preferredHeight;
@synthesize delegate = _delegate;

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
    
    [self setFollowersCount:nil];
    [self setFollowingCount:nil];

    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");

    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];

    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowering:)]];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    self.user = [self.dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManagerUserKey];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self applyStyle];
}

- (void)clearBackgroundImage
{
    [self.backgroundImageView setImage:nil];
}

#pragma mark - VUserProfileHeader

- (UIView *)floatingProfileImage
{
    return nil;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.userStatsBarBackgroundContainer;
}

#pragma mark - Setters

- (void)setUser:(VUser *)user
{
    BOOL isSameUser = user != nil && user == _user;
    
    _user = user;
    
    if ( !isSameUser )
    {
        [self clearBackgroundImage];
    }

    [self updateUser];
}

- (void)updateUser
{
    [self updateProfileImage];
    
    if ( self.user != nil )
    {
        [self cleanupKVOControllerWithUser:self.user];
    }
    
    [self applyStyle];
    [self setupKVOControllerWithUser:self.user];
}

- (void)updateProfileImage
{
    NSAssert( NO, @"Must be overridden by subclasses." );
}

- (void)setState:(VUserProfileHeaderState)state
{
    _state = state;
    
    [self updateUser];
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

- (void)applyStyle
{
    NSString *editButtonStyle = [self.dependencyManager stringForKey:VDependencyManagerProfileEditButtonStyleKey];
    const BOOL isRounded = [editButtonStyle isEqualToString:VDependencyManagerProfileEditButtonStylePill];
    [self.primaryActionButton layoutIfNeeded];
    const CGFloat roundedCornerRadius = CGRectGetHeight( self.primaryActionButton.bounds ) / 2.0f;
    self.primaryActionButton.cornerRadius = isRounded ? roundedCornerRadius : 0.0f;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
}

#pragma mark - Actions

- (IBAction)pressedPrimaryAction:(id)sender
{
    [self.delegate primaryActionHandler];
}

- (IBAction)pressedFollowers:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowers];
    
    [self.delegate followerHandler];
}

- (IBAction)pressedFollowering:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectProfileFollowing];
    
    [self.delegate followingHandler];
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
         [welf updateProfileImage];
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
    self.nameLabel.text = self.user.name != nil ? self.user.name : @"";
    self.locationLabel.text = self.user.location;
    self.taglineLabel.text = self.user.tagline;
}

@end
