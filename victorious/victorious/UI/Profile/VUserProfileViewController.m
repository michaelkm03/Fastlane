//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileViewController.h"
#import "VUser.h"
#import "UIViewController+VSideMenuViewController.h"
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

#import "VStream+Fetcher.h"

#import "VObjectManager+ContentCreation.h"

#import "VInboxContainerViewController.h"

#import "VUserProfileHeaderView.h"
#import "VProfileHeaderCell.h"
#import "VContainerViewController.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VFindFriendsViewController.h"
#import "UIViewController+VNavMenu.h"
#import "VSettingManager.h"

static const CGFloat kVSmallUserHeaderHeight = 319.0f;

static void * VUserProfileViewContext = &VUserProfileViewContext;
static void * VUserProfileAttributesContext =  &VUserProfileAttributesContext;
static NSString * const kUserKey = @"user";

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, VNavigationHeaderDelegate>

@property   (nonatomic, strong) VUser                  *profile;

@property (nonatomic, strong) VUserProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) VProfileHeaderCell *currentProfileCell;
@property (nonatomic) CGSize currentProfileSize;

@property (nonatomic, strong) UIImageView              *backgroundImageView;
@property (nonatomic) BOOL                            isMe;

@property (nonatomic, strong) VProfileFollowingContainerViewController *followingAndHashtagsVC;

@end

@implementation VUserProfileViewController

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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.streamDataSource.hasHeaderCell = YES;
    
    self.isMe = (self.profile.remoteId.integerValue == [VObjectManager sharedManager].mainUser.remoteId.integerValue);
    
    UIColor *backgroundColor = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? [UIColor clearColor] : [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateDidChange:) name:kLoggedInChangedNotification object:nil];
    }
    
    [self.currentStream addObserver:self
                         forKeyPath:@"sequences"
                            options:NSKeyValueObservingOptionNew
                            context:VUserProfileViewContext];
    
    [self.collectionView registerClass:[VProfileHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass([VProfileHeaderCell class])];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self v_addNewNavHeaderWithTitles:nil];
    self.navHeaderView.delegate = self;
    
    if (self.isMe)
    {
        [self addFriendsButton];
    }
    else if (!self.isMe && !self.profile.isDirectMessagingDisabled.boolValue)
    {
        BOOL isTemplateC = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
        UIImage *composeImage = isTemplateC ? [UIImage imageNamed:@"compose_btn"] : [UIImage imageNamed:@"profileCompose"];
        [self.navHeaderView setRightButtonImage:composeImage withAction:@selector(composeMessage:) onTarget:self];
    }
    
    [super viewWillAppear:animated]; //Call super after the header is set up so the super class will set up the headers properly.
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    CGFloat height = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.navHeaderView.frame);
    height = self.streamDataSource.count ? kVSmallUserHeaderHeight : height;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.currentProfileSize = CGSizeMake(width, height);
    
    if ( self.profileHeaderView == nil )
    {
        VUserProfileHeaderView *headerView =  [VUserProfileHeaderView newViewWithFrame:CGRectMake(0, 0, width, height)];
        headerView.user = self.profile;
        headerView.delegate = self;
        self.profileHeaderView = headerView;
    }

    UIImage    *defaultBackgroundImage;
    if (self.backgroundImageView.image)
    {
        defaultBackgroundImage = self.backgroundImageView.image;
    }
    else
    {
        defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyLightEffect];
    }
    
    [self.backgroundImageView removeFromSuperview];
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
    
    if (self.streamDataSource.count)
    {
        [self animateHeaderShrinkingWithDuration:0.0f];
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
}

- (void)dealloc
{
    [self.currentStream removeObserver:self forKeyPath:@"sequences"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
    if (self.profile != nil)
    {
        [self stopObservingUserProfile];
    }
}

#pragma mark - Find Friends

- (void)addFriendsButton
{
    [self.navHeaderView setRightButtonImage:[UIImage imageNamed:@"findFriendsIcon"]
                                 withAction:@selector(findFriendsAction:)
                                   onTarget:self];
}

- (IBAction)findFriendsAction:(id)sender
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
        return;
    }
    
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
    
    [_profile addObserver:self forKeyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [_profile addObserver:self forKeyPath:NSStringFromSelector(@selector(location)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [_profile addObserver:self forKeyPath:NSStringFromSelector(@selector(tagline)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [_profile addObserver:self forKeyPath:NSStringFromSelector(@selector(pictureUrl)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    
    self.currentStream = [VStream streamForUser:self.profile];
    if ([self isViewLoaded])
    {
        [self refresh:nil];
    }
}

#pragma mark - Support

- (void)stopObservingUserProfile
{
    [_profile removeObserver:self forKeyPath:NSStringFromSelector(@selector(name)) context:VUserProfileAttributesContext];
    [_profile removeObserver:self forKeyPath:NSStringFromSelector(@selector(location)) context:VUserProfileAttributesContext];
    [_profile removeObserver:self forKeyPath:NSStringFromSelector(@selector(tagline)) context:VUserProfileAttributesContext];
    [_profile removeObserver:self forKeyPath:NSStringFromSelector(@selector(pictureUrl)) context:VUserProfileAttributesContext];
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
    void (^fullCompletionBlock)(void) = ^void(void)
    {
        if (self.streamDataSource.count)
        {
            [self animateHeaderShrinkingWithDuration:.5f];
        }
        if (completionBlock)
        {
            completionBlock();
        }
    };
    [super refreshWithCompletion:fullCompletionBlock];
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

- (void)animateHeaderShrinkingWithDuration:(CGFloat)duration
{
    CGSize newSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), kVSmallUserHeaderHeight);
    
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.95f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^
     {
         self.currentProfileSize = newSize;

         self.currentProfileCell.bounds = CGRectMake(CGRectGetMinX(self.collectionView.frame),
                                                     CGRectGetMinY(self.collectionView.frame),
                                                     newSize.width,
                                                     newSize.height);
         [self.currentProfileCell layoutIfNeeded];
     }
                     completion:nil];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath
{
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
    {
        VProfileHeaderCell *headerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([VProfileHeaderCell class]) forIndexPath:indexPath];
        headerCell.headerView = self.profileHeaderView;
        self.currentProfileCell = headerCell;
        return headerCell;
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
        if (self.streamDataSource.count)
        {
            [self animateHeaderShrinkingWithDuration:.5];
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
