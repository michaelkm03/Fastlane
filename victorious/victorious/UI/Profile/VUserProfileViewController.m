//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileViewController.h"
#import "VUser.h"
#import "VLoginViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VRootViewController.h"
#import "VFollowerTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VProfileFollowingContainerViewController.h"
#import "VMessageContainerViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+Blurring.h"
#import "VThemeManager.h"
#import "VObjectManager+Login.h"
#import <UIImageView+WebCache.h>
#import "VStream+Fetcher.h"

#import "VObjectManager+ContentCreation.h"

#import "VInboxContainerViewController.h"

#import "VUserProfileHeaderView.h"
#import "VProfileHeaderCell.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VFindFriendsViewController.h"
#import "VSettingManager.h"
#import <FBKVOController.h>
#import <MBProgressHUD.h>

static const CGFloat kVSmallUserHeaderHeight = 319.0f;

static void * VUserProfileViewContext = &VUserProfileViewContext;
static void * VUserProfileAttributesContext =  &VUserProfileAttributesContext;
/*
 According to MBProgressHUD.h, a 37 x 37 square is the best fit for a custom view within a MBProgressHUD
 */
static const CGFloat MBProgressHUDCustomViewSide = 37.0f;
static NSString * const kUserKey = @"user";

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, MBProgressHUDDelegate>

@property   (nonatomic, strong) VUser                  *profile;
@property (nonatomic, strong) NSNumber *remoteId;

@property (nonatomic, strong) VUserProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) VProfileHeaderCell *currentProfileCell;
@property (nonatomic) CGSize currentProfileSize;

@property (nonatomic, strong) UIImageView              *backgroundImageView;
@property (nonatomic) BOOL                            isMe;

@property (nonatomic, strong) VProfileFollowingContainerViewController *followingAndHashtagsVC;

@property (nonatomic, strong) MBProgressHUD *retryHUD;
@property (nonatomic, strong) UIButton *retryProfileLoadButton;

@property (nonatomic, assign) BOOL didEndViewWillAppear;

@property (nonatomic, assign) CGFloat defaultMBProgressHUDMargin;

@end

@implementation VUserProfileViewController

+ (instancetype)userProfileWithRemoteId:(NSNumber *)remoteId
{
    VUserProfileViewController   *viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    viewController.dependencyManager = [[VRootViewController rootViewController] dependencyManager];
    
    VUser *mainUser = [VObjectManager sharedManager].mainUser;
    BOOL isMe = (remoteId.integerValue == mainUser.remoteId.integerValue);
    
    if ( !isMe )
    {
        [viewController loadUserWithRemoteId:remoteId];
    }
    else
    {
        viewController.profile = mainUser;
    }
    
    return viewController;
}

+ (instancetype)userProfileWithUser:(VUser *)aUser
{
    VUserProfileViewController   *viewController  =   [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    viewController.profile = aUser;
    
    BOOL isMe = (aUser.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    if (isMe)
    {
        viewController.title = NSLocalizedString(@"me", "");
    }
    else
    {
        viewController.title = aUser.name ?: @"Profile";
    }
    
    viewController.dependencyManager = [[VRootViewController rootViewController] dependencyManager];
    return viewController;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUser *user = [dependencyManager templateValueOfType:[VUser class] forKey:kUserKey];
    if (user != nil)
    {
        return [self userProfileWithUser:user];
    }
    return nil;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.streamDataSource.hasHeaderCell = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    UIColor *backgroundColor = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? [UIColor clearColor] : [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateDidChange:) name:kLoggedInChangedNotification object:nil];
    }
    
    [self.KVOController observe:self.currentStream
                        keyPath:@"sequences"
                        options:NSKeyValueObservingOptionNew
                        context:VUserProfileViewContext];
    
    [self.collectionView registerClass:[VProfileHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass([VProfileHeaderCell class])];
    
    UIImage    *defaultBackgroundImage;
    if (self.backgroundImageView.image)
    {
        defaultBackgroundImage = self.backgroundImageView.image;
    }
    else
    {
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyLightEffect];
    }
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                                    placeholderImage:defaultBackgroundImage
                                           tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    self.view.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    
    if (![[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled])
    {
        self.collectionView.backgroundView = self.backgroundImageView;
    }
    else
    {
        [self.profileHeaderView insertSubview:self.backgroundImageView atIndex:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isMe)
    {
        [self addFriendsButton];
    }
    else if (!self.isMe && !self.profile.isDirectMessagingDisabled.boolValue)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(composeMessage:)];
    }

    NSURL *pictureURL = [NSURL URLWithString:self.profile.pictureUrl];
    if (![self.backgroundImageView.sd_imageURL isEqual:pictureURL])
    {
        [self.backgroundImageView setBlurredImageWithURL:pictureURL
                                        placeholderImage:self.backgroundImageView.image
                                               tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    }
    
    if ( self.streamDataSource.count != 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
    
    //If we came from the inbox we can get into a loop with the compose button, so hide it
    BOOL fromInbox = NO;
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VInboxContainerViewController class]])
        {
            fromInbox = YES;
        }
    }
    if (fromInbox)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.didEndViewWillAppear = YES;
    [self attemptToRefreshProfileUI];
}

- (void)loadUserWithRemoteId:(NSNumber *)remoteId
{
    self.remoteId = remoteId;
    if ( self.retryHUD == nil )
    {
        self.retryHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.defaultMBProgressHUDMargin = self.retryHUD.margin;
    }
    else
    {
        self.retryHUD.margin = self.defaultMBProgressHUDMargin;
        self.retryHUD.mode = MBProgressHUDModeIndeterminate;
    }

    [[VObjectManager sharedManager] fetchUser:self.remoteId
                             withSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self.retryHUD hide:YES];
         [self.retryProfileLoadButton removeFromSuperview];
         self.retryHUD = nil;
         self.profile = [resultObjects lastObject];
     }
                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         //Handle profile load failure by changing navigationItem title and showing a retry button in the indicator
         self.navigationItem.title = NSLocalizedString(@"Profile load failed!", @"");
         self.retryHUD.mode = MBProgressHUDModeCustomView;
         self.retryHUD.customView = self.retryProfileLoadButton;
         self.retryHUD.margin = 0.0f;
         [self.retryProfileLoadButton setUserInteractionEnabled:YES];
     }];
}

- (void)retryProfileLoad
{
    //Disable user interaction to avoid spamming
    [self.retryProfileLoadButton setUserInteractionEnabled:NO];
    [self loadUserWithRemoteId:self.remoteId];
}

- (UIButton *)retryProfileLoadButton
{
    if ( _retryProfileLoadButton != nil )
    {
        return _retryProfileLoadButton;
    }
    
    /*
     To make a full-HUD button, it needs to have origin (-margin, -margin) and size (margin * 2 + MBProgressHUDCustomViewSide, margin * 2 + MBProgressHUDCustomViewSide).
    */
    CGFloat margin = self.defaultMBProgressHUDMargin;
    CGFloat buttonSide = margin * 2 + MBProgressHUDCustomViewSide;
    _retryProfileLoadButton = [[UIButton alloc] initWithFrame:CGRectMake(-margin, -margin, buttonSide, buttonSide)];
    [_retryProfileLoadButton addTarget:self action:@selector(retryProfileLoad) forControlEvents:UIControlEventTouchUpInside];
    _retryProfileLoadButton.tintColor = [UIColor whiteColor];
    [_retryProfileLoadButton setImage:[[UIImage imageNamed:@"uploadRetryButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    return _retryProfileLoadButton;
}

- (VUserProfileHeaderView *)profileHeaderView
{
    if ( _profileHeaderView != nil )
    {
        return _profileHeaderView;
    }
    
    VUserProfileHeaderView *headerView =  [VUserProfileHeaderView newView];
    headerView.user = self.profile;
    headerView.delegate = self;
    _profileHeaderView = headerView;
    return _profileHeaderView;
}

- (void)viewDidLayoutSubviews
{
    CGFloat height = CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length;
    height = self.streamDataSource.count ? kVSmallUserHeaderHeight : height;
    
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    CGSize newProfileSize = CGSizeMake(width, height);

    if ( !CGSizeEqualToSize(newProfileSize, self.currentProfileSize) )
    {
        self.currentProfileSize = newProfileSize;
    }
}

- (void)dealloc
{
    [self.KVOController unobserve:self.currentStream keyPath:@"sequences"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
    if (self.profile != nil)
    {
        [self stopObservingUserProfile];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueUserProfile forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
}

#pragma mark - Find Friends

- (void)addFriendsButton
{
    BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
    UIImage *findFriendsIcon = isTemplateC ? [UIImage imageNamed:@"findFriendsIconC"] : [UIImage imageNamed:@"findFriendsIcon"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:findFriendsIcon
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(findFriendsAction:)];
}

- (IBAction)findFriendsAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }

    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectFindFriends];
    
    VFindFriendsViewController *ffvc = [VFindFriendsViewController newFindFriendsViewController];
    [ffvc setShouldAutoselectNewFriends:NO];
    [self.navigationController pushViewController:ffvc animated:YES];
}

#pragma mark - Accessors

- (NSString *)viewName
{
    return @"Profile";
}

- (void)setProfile:(VUser *)profile
{
    if (profile == _profile)
    {
        return;
    }
    
    [self stopObservingUserProfile];
    
    _profile = profile;
    
    BOOL isMe = (profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    NSString *profileName = profile.name ?: @"Profile";
    
    self.title = isMe ? NSLocalizedString(@"me", "") : profileName;
    
    [self.KVOController observe:_profile keyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_profile keyPath:NSStringFromSelector(@selector(location)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_profile keyPath:NSStringFromSelector(@selector(tagline)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_profile keyPath:NSStringFromSelector(@selector(pictureUrl)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    
    self.currentStream = [VStream streamForUser:self.profile];
    
    //Update title AFTER updating current stream as that update resets the title to nil (because there is nil name in the stream)
    self.navigationItem.title = profileName;

    [self attemptToRefreshProfileUI];
}

- (void)attemptToRefreshProfileUI
{
    //Ensuring viewWillAppear has finished and we have a valid profile ensures smooth profile and stream presentation by avoiding unnecessary refreshes even when loading from a remoteId
    if ( self.didEndViewWillAppear && self.profile != nil )
    {
        CGFloat height = CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length;
        height = self.streamDataSource.count ? kVSmallUserHeaderHeight : height;
        
        CGFloat width = CGRectGetWidth(self.view.bounds);
        self.currentProfileSize = CGSizeMake(width, height);
        
        self.profileHeaderView.user = self.profile;
        
        if ( self.streamDataSource.count == 0 )
        {
            [self refresh:nil];
        }
        else
        {
            [self shrinkHeaderAnimated:YES];
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - Support

- (void)stopObservingUserProfile
{
    [self.KVOController unobserve:_profile keyPath:NSStringFromSelector(@selector(name))];
    [self.KVOController unobserve:_profile keyPath:NSStringFromSelector(@selector(location))];
    [self.KVOController unobserve:_profile keyPath:NSStringFromSelector(@selector(tagline))];
    [self.KVOController unobserve:_profile keyPath:NSStringFromSelector(@selector(pictureUrl))];
}

- (void)loginStateDidChange:(NSNotification *)notification
{
    if ([VObjectManager sharedManager].mainUser)
    {
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.profile
                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             VUserProfileHeaderView *header = self.profileHeaderView;
             header.isFollowingUser = [resultObjects[0] boolValue];
             header.user = header.user;
         }
                                     failBlock:nil];
    }
}

#pragma mark - Actions

- (void)refreshWithCompletion:(void (^)(void))completionBlock
{
    if ( self.profile != nil )
    {
        void (^fullCompletionBlock)(void) = ^void(void)
        {
            if (self.streamDataSource.count)
            {
                [self shrinkHeaderAnimated:YES];
            }
            if (completionBlock)
            {
                completionBlock();
            }
        };
        [super refreshWithCompletion:fullCompletionBlock];
    }
}

- (IBAction)composeMessage:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]]
                           animated:YES
                         completion:NULL];
        return;
    }

    VMessageContainerViewController    *composeController   = [VMessageContainerViewController messageViewControllerForUser:self.profile];
    composeController.presentingFromProfile = YES;
    
    if ([self.navigationController.viewControllers containsObject:composeController])
    {
        [self.navigationController popToViewController:composeController animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:composeController animated:YES];
    }
}

- (void)editProfileHandler
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
    if (self.isMe)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectEditProfile];
        
        [self performSegueWithIdentifier:@"toEditProfile" sender:self];
        return;
    }
    
    VUserProfileHeaderView *header = self.profileHeaderView;
    header.editProfileButton.enabled = NO;
    
    [self.profileHeaderView.editProfileButton showActivityIndicator];
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        header.editProfileButton.enabled = YES;
        [header.editProfileButton hideActivityIndicator];
        
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"UnfollowError", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                          otherButtonTitles:nil] show];
    };
    
    if ( header.isFollowingUser )
    {
        [[VObjectManager sharedManager] unfollowUser:self.profile
                                        successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             header.editProfileButton.enabled = YES;
             header.isFollowingUser = NO;
             header.numberOfFollowers--;
         }
                                           failBlock:fail];
    }
    else
    {
        [[VObjectManager sharedManager] followUser:self.profile
                                      successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             header.editProfileButton.enabled = YES;
             header.isFollowingUser = YES;
             header.numberOfFollowers++;
         }
                                         failBlock:fail];
    }
}

#pragma mark - Navigation

- (void)followerHandler
{
    [self performSegueWithIdentifier:@"toFollowers" sender:self];
}

- (void)followingHandler
{
    if (self.isMe)
    {
        [self performSegueWithIdentifier:@"toHashtagsAndFollowing" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"toFollowing" sender:self];
    }
}

#pragma mark - Animation

- (void)shrinkHeaderAnimated:(BOOL)animated
{
    if ( !animated )
    {
        self.currentProfileSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), kVSmallUserHeaderHeight);
        [self.currentProfileCell invalidateIntrinsicContentSize];
    }
    else
    {
        self.currentProfileSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), kVSmallUserHeaderHeight);
        CGRect newFrame = self.currentProfileCell.frame;
        newFrame.size.height = self.currentProfileSize.height;
        [UIView animateWithDuration:0.4f
                              delay:0.0f
             usingSpringWithDamping:0.95f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             [self.currentProfileCell setFrame:newFrame];
             [self.currentProfileCell layoutIfNeeded];
         }
                         completion:nil];
    }
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        if ( self.currentProfileCell == nil )
        {
            VProfileHeaderCell *headerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([VProfileHeaderCell class]) forIndexPath:indexPath];
            headerCell.headerView = self.profileHeaderView;
            self.currentProfileCell = headerCell;
        }
        self.currentProfileCell.hidden = self.profile == nil;
        return self.currentProfileCell;
    }
    return [super dataSource:dataSource cellForIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return self.currentProfileSize;
    }
    return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        return;
    }
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == VUserProfileAttributesContext)
    {
        [self.collectionView reloadData];
        return;
    }
    
    if (context != VUserProfileViewContext)
    {
        return;
    }
    
    if (object == self.currentStream && [keyPath isEqualToString:NSStringFromSelector(@selector(streamItems))])
    {
        if ( self.streamDataSource.count != 0 )
        {
            [self shrinkHeaderAnimated:YES];
        }
    }
    
    [self.currentStream removeObserver:self
                            forKeyPath:NSStringFromSelector(@selector(streamItems))];
}

@end

#pragma mark -

@implementation VDependencyManager (VUserProfileViewControllerAdditions)

- (VUserProfileViewController *)userProfileViewControllerWithUser:(VUser *)user forKey:(NSString *)key
{
    NSAssert(user != nil, @"user can't be nil");
    return [self templateValueOfType:[VUserProfileViewController class] forKey:key withAddedDependencies:@{ kUserKey: user }];
}

@end
