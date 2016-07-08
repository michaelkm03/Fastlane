//
//  VAbstractUserProfileHeaderViewController.m
//  victorious
//
//  Created by Patrick Lynch on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractUserProfileHeaderViewController.h"
#import "VDependencyManager.h"
#import "VLargeNumberFormatter.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VImageAssetFinder.h"
#import "victorious-Swift.h"

@import SDWebImage;
@import KVOController;

@interface VAbstractUserProfileHeaderViewController() <VBackgroundContainer>

@property (nonatomic, strong) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VAbstractUserProfileHeaderViewController

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
    
    self.nameLabel.accessibilityIdentifier = VAutomationIdentifierProfileUsernameTitle;
    
    [self setFollowersCount:nil];
    [self setFollowingCount:nil];

    self.followersHeader.text = NSLocalizedString(@"FOLLOWERS", @"");

    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowers:)]];

    self.followingHeader.text = NSLocalizedString(@"FOLLOWING", @"");
    
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressedFollowing:)]];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    
    self.user = [self.dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManager.userKey];
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

- (void)addTrophyCaseButton:(UIButton *)button
{
    // Implement in subclasses
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
    [self userHasChanged];
}

- (void)reloadProfileImage
{
    NSAssert( NO, @"Must be overridden by subclasses." );
}

- (void)updateProfileImage
{
    NSAssert( NO, @"Must be overridden by subclasses." );
}

- (void)userHasChanged
{
    // Implement in sublass
}

- (void)setState:(VUserProfileHeaderState)state
{
    _state = state;
    
    [self updateUser];
}

- (void)setFollowersCount:(NSNumber *)followersCount
{
    BOOL hasFollowersCount = followersCount != nil && followersCount.integerValue >= 0;
    if ( hasFollowersCount )
    {
        self.followersLabel.text = [self.largeNumberFormatter stringForInteger:followersCount.integerValue];
    }
    self.followersButton.hidden = !hasFollowersCount;
    self.followersHeader.hidden = !hasFollowersCount;
    self.followersLabel.hidden = !hasFollowersCount;
}

- (void)setFollowingCount:(NSNumber *)followingCount
{
    BOOL hasFollowingCount = followingCount != nil && followingCount.integerValue >= 0;
    if ( hasFollowingCount )
    {
        self.followingLabel.text = [self.largeNumberFormatter stringForInteger:followingCount.integerValue];
    }
    self.followingButton.hidden = !hasFollowingCount;
    self.followingHeader.hidden = !hasFollowingCount;
    self.followingLabel.hidden = !hasFollowingCount;
}

- (void)applyStyle
{
    NSString *editButtonStyle = [self.dependencyManager stringForKey:VDependencyManager.profileEditButtonStyleKey];
    const BOOL isRounded = [editButtonStyle isEqualToString:VDependencyManager.profileEditButtonStylePill];
    [self.primaryActionButton layoutIfNeeded];
    const CGFloat roundedCornerRadius = CGRectGetHeight( self.primaryActionButton.bounds ) / 2.0f;
    self.primaryActionButton.cornerRadius = isRounded ? roundedCornerRadius : 0.0f;
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    if ([AgeGate isAnonymousUser])
    {
        [self.primaryActionButton removeFromSuperview];
        self.primaryActionButton = nil;
    }
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

- (IBAction)pressedFollowing:(id)sender
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
    
    [self.KVOController observe:user keyPath:NSStringFromSelector(@selector(previewAssets))
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
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
