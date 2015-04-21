//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <FBKVOController.h>
#import <MBProgressHUD.h>

#import "VUserProfileViewController.h"
#import "VUser.h"
#import "VLoginViewController.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+DirectMessaging.h"
#import "VProfileEditViewController.h"
#import "VFollowerTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VMessageContainerViewController.h"
#import "VObjectManager+Login.h"
#import "VStream+Fetcher.h"
#import "VObjectManager+ContentCreation.h"
#import "VInboxViewController.h"
#import "VProfileHeaderCell.h"
#import "VAuthorizedAction.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VFindFriendsViewController.h"
#import "VSettingManager.h"
#import "VDependencyManager.h"
#import "VBaseCollectionViewCell.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"
#import "VUserProfileHeader.h"
#import "VDependencyManager+VUserProfile.h"

static void * VUserProfileViewContext = &VUserProfileViewContext;
static void * VUserProfileAttributesContext =  &VUserProfileAttributesContext;

// According to MBProgressHUD.h, a 37 x 37 square is the best fit for a custom view within a MBProgressHUD
static const CGFloat MBProgressHUDCustomViewSide = 37.0f;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, MBProgressHUDDelegate, VNotAuthorizedDataSourceDelegate>

@property (nonatomic, assign) BOOL didEndViewWillAppear;
@property (nonatomic, assign) BOOL isMe;

@property (nonatomic, assign) CGSize currentProfileSize;
@property (nonatomic, assign) CGFloat defaultMBProgressHUDMargin;
@property (nonatomic, strong) NSNumber *remoteId;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) VUser *user;
@property (nonatomic, strong) UIViewController<VUserProfileHeader> *profileHeaderViewController;
@property (nonatomic, strong) VProfileHeaderCell *currentProfileCell;
@property (nonatomic, strong) VNotAuthorizedDataSource *notLoggedInDataSource;
@property (nonatomic, strong) UIButton *retryProfileLoadButton;

@property (nonatomic, strong) MBProgressHUD *retryHUD;

@end

@implementation VUserProfileViewController

+ (instancetype)userProfileWithRemoteId:(NSNumber *)remoteId andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(dependencyManager != nil);
    VUserProfileViewController *viewController = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    //Set the dependencyManager before setting the profile since setting the profile creates the profileHeaderViewController
    viewController.dependencyManager = dependencyManager;
    
    VUser *mainUser = [VObjectManager sharedManager].mainUser;
    const BOOL isCurrentUser = (mainUser != nil && [remoteId isEqualToNumber:mainUser.remoteId]);
    if ( isCurrentUser )
    {
        viewController.user = mainUser;
    }
    else
    {
        viewController.remoteId = remoteId;
    }
    
    return viewController;
}

+ (instancetype)userProfileWithUser:(VUser *)aUser andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(dependencyManager != nil);
    VUserProfileViewController *viewController = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    
    //Set the dependencyManager before setting the profile since setting the profile creates the profileHeaderViewController
    viewController.dependencyManager = dependencyManager;
    
    viewController.user = aUser;
    
    VUser *mainUser = [VObjectManager sharedManager].mainUser;
    const BOOL isCurrentUser = (mainUser != nil && [aUser.remoteId isEqualToNumber:mainUser.remoteId]);
    if ( isCurrentUser )
    {
        viewController.title = NSLocalizedString(@"me", "");
    }
    else
    {
        viewController.title = aUser.name ?: @"Profile";
    }
    
    return viewController;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUser *user = [dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManagerUserKey];
    if ( user != nil )
    {
        return [self userProfileWithUser:user andDependencyManager:dependencyManager];
    }
    
    NSNumber *remoteId = [dependencyManager templateValueOfType:[NSNumber class] forKey:VDependencyManagerUserRemoteIdKey];
    if ( remoteId != nil )
    {
        return [self userProfileWithRemoteId:remoteId andDependencyManager:dependencyManager];
    }
    
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        [self userProfileSharedInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
    {
        [self userProfileSharedInit];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateDidChange:)
                                                 name:kLoggedInChangedNotification object:nil];

    [self.dependencyManager addPropertiesToNavigationItem:self.navigationItem
                                 pushAccessoryMenuItemsOn:self.navigationController];
    
    self.streamDataSource.hasHeaderCell = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = backgroundColor;
    
    [self.KVOController unobserve:self.currentStream keyPath:@"sequences"];
    [self.KVOController observe:self.currentStream
                        keyPath:@"sequences"
                        options:NSKeyValueObservingOptionNew
                        context:VUserProfileViewContext];
    
    [self.collectionView registerClass:[VProfileHeaderCell class]
            forCellWithReuseIdentifier:NSStringFromClass([VProfileHeaderCell class])];
    
    [self updateCollectionViewDataSource];
    
    [self createProfileHeader];
}

- (void)createProfileHeader
{
    if ( self.user != nil )
    {
        self.profileHeaderViewController = [self.dependencyManager userProfileHeaderWithUser:self.user];
        self.profileHeaderViewController.delegate = self;
        if ( self.profileHeaderViewController != nil )
        {
            self.streamDataSource.hasHeaderCell = YES;
            self.profileHeaderViewController.delegate = self;
            [self reloadUserFollowCounts];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setInitialHeaderState];
    
    if ( self.isCurrentUser )
    {
        [self addFriendsButton];
    }
    else if ( self.user == nil && self.remoteId != nil )
    {
        [self loadUserWithRemoteId:self.remoteId];
    }
    else if (!self.isCurrentUser && !self.user.isDirectMessagingDisabled.boolValue)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(composeMessage:)];
    }
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.view.backgroundColor = backgroundColor;
    
    if ( self.streamDataSource.count != 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
    
    //If we came from the inbox we can get into a loop with the compose button, so hide it
    BOOL fromInbox = NO;
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VInboxViewController class]])
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

- (void)viewDidLayoutSubviews
{
    CGFloat height = CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length;
    height = self.streamDataSource.count ? self.profileHeaderViewController.preferredHeight : height;
    
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    CGSize newProfileSize = CGSizeMake(width, height);
    
    if ( !CGSizeEqualToSize(newProfileSize, self.currentProfileSize) )
    {
        self.currentProfileSize = newProfileSize;
    }
}

- (void)dealloc
{
    if (self.currentStream != nil)
    {
        [self.KVOController unobserve:self.currentStream keyPath:@"sequences"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
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

#pragma mark -

- (void)userProfileSharedInit
{
    self.canShowContent = NO;
}

- (BOOL)canShowMarquee
{
    //This will stop our superclass from adjusting the "hasHeaderCell" property, which in turn affects whether or
    // not the profileHeader is shown, based on whether or not this stream contains a marquee
    return NO;
}

- (BOOL)isCurrentUser
{
    const VUser *loggedInUser = [VObjectManager sharedManager].mainUser;
    return loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];
}

#pragma mark - Loading data

- (void)reloadUserFollowCounts
{
    [[VObjectManager sharedManager] countOfFollowsForUser:self.user successBlock:nil failBlock:nil];
}

- (void)setInitialHeaderState
{
    if ( self.profileHeaderViewController == nil )
    {
        return;
    }
    
    if ( self.isCurrentUser )
    {
        self.profileHeaderViewController.state = VUserProfileHeaderStateCurrentUser;
    }
    else
    {
        self.profileHeaderViewController.state = VUserProfileHeaderStateNotFollowingUser;
        [self reloadUserFollowCounts];
    }
}

- (void)reloadUserFollowingRelationship
{
    if ( self.isCurrentUser )
    {
        return;
    }
    
    id<VUserProfileHeader> header = self.profileHeaderViewController;
    if ( header == nil )
    {
        return;
    }
    
    if ([VObjectManager sharedManager].mainUser)
    {
        header.isLoading = YES;
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.user
                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             header.isLoading = NO;
             const BOOL isFollowingUser = [resultObjects.firstObject boolValue];
             header.state = isFollowingUser ? VUserProfileHeaderStateFollowingUser : VUserProfileHeaderStateNotFollowingUser;
         }
                                     failBlock:^(NSOperation *operation, NSError *error)
         {
             header.isLoading = NO;
         }];
    }
    else
    {
        header.state = VUserProfileHeaderStateNotFollowingUser;
    }
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
         self.user = [resultObjects lastObject];
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

- (void)attemptToRefreshProfileUI
{
    //Ensuring viewWillAppear has finished and we have a valid profile ensures smooth profile and stream presentation by avoiding unnecessary refreshes even when loading from a remoteId
    if ( self.didEndViewWillAppear && self.user != nil )
    {
        CGFloat height = CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length;
        height = self.streamDataSource.count ? self.profileHeaderViewController.preferredHeight : height;
        
        CGFloat width = CGRectGetWidth(self.view.bounds);
        self.currentProfileSize = CGSizeMake(width, height);
        
        [self reloadUserFollowingRelationship];
        
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

- (void)refreshWithCompletion:(void (^)(void))completionBlock
{
    if (self.collectionView.dataSource == self.notLoggedInDataSource)
    {
        if (completionBlock)
        {
            completionBlock();
        }
        return;
    }
    else
    {
        if ( self.user != nil )
        {
            void (^fullCompletionBlock)(void) = ^void(void)
            {
                if (self.streamDataSource.count)
                {
                    [self shrinkHeaderAnimated:YES];
                }
                if ( completionBlock != nil )
                {
                    completionBlock();
                }
            };
            [super refreshWithCompletion:fullCompletionBlock];
        }
    }
}

- (void)toggleFollowUser
{
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        self.profileHeaderViewController.isLoading = NO;
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"UnfollowError", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
    };
    
    if ( self.profileHeaderViewController.state == VUserProfileHeaderStateFollowingUser )
    {
        self.profileHeaderViewController.isLoading = YES;
        [[VObjectManager sharedManager] unfollowUser:self.user
                                        successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             self.profileHeaderViewController.state = VUserProfileHeaderStateNotFollowingUser;
         }
                                           failBlock:fail];
    }
    else if ( self.profileHeaderViewController.state == VUserProfileHeaderStateNotFollowingUser )
    {
        self.profileHeaderViewController.isLoading = YES;
        [[VObjectManager sharedManager] followUser:self.user
                                      successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             self.profileHeaderViewController.state = VUserProfileHeaderStateFollowingUser;
         }
                                         failBlock:fail];
    }
}

#pragma mark - Login status change

- (void)loginStateDidChange:(NSNotification *)notification
{
    if ( [VObjectManager sharedManager].authorized )
    {
        [self reloadUserFollowingRelationship];
    }
    else if ( self.representsMainUser )
    {
        self.user = [VObjectManager sharedManager].mainUser;
        [self updateCollectionViewDataSource];
    }
}

#pragma mark - Find Friends

- (void)addFriendsButton
{
    //Previously was C_findFriendsIcon in template C
    UIImage *findFriendsIcon = [self.dependencyManager imageForKey:VDependencyManagerFindFriendsIconKey];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:findFriendsIcon
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(findFriendsAction:)];
}

#pragma mark - Accessors

- (NSString *)viewName
{
    return @"Profile";
}

#pragma mark - Actions

- (IBAction)findFriendsAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectFindFriends];
    
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:VAuthorizationContextInbox completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         VFindFriendsViewController *ffvc = [VFindFriendsViewController newWithDependencyManager:self.dependencyManager];
         [ffvc setShouldAutoselectNewFriends:NO];
         [self.navigationController pushViewController:ffvc animated:YES];
     }];
}

- (void)setUser:(VUser *)user
{
    NSAssert(self.dependencyManager != nil, @"dependencyManager should not be nil in VUserProfileViewController when the profile is set");
    
    if ( user == _user )
    {
        return;
    }
    
    _user = user;
    
    self.profileHeaderViewController.user = user;

    NSString *profileName = user.name ?: @"Profile";
    
    self.title = self.isCurrentUser ? NSLocalizedString(@"me", "") : profileName;
    
    self.currentStream = [VStream streamForUser:self.user];
    
    //Update title AFTER updating current stream as that update resets the title to nil (because there is nil name in the stream)
    self.navigationItem.title = profileName;

    [self attemptToRefreshProfileUI];
}

- (IBAction)composeMessage:(id)sender
{
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:VAuthorizationContextInbox completion:^(BOOL authorized)
     {
         if (!authorized)
         {
             return;
         }
         
         VMessageContainerViewController *composeController = [VMessageContainerViewController messageViewControllerForUser:self.user dependencyManager:self.dependencyManager];
         composeController.presentingFromProfile = YES;
         
         if ([self.navigationController.viewControllers containsObject:composeController])
         {
             [self.navigationController popToViewController:composeController animated:YES];
         }
         else
         {
             [self.navigationController pushViewController:composeController animated:YES];
         }
     }];
}

#pragma mark - VUserProfileHeaderDelegate

- (void)secondaryActionHandler
{
    
}

- (void)primaryActionHandler
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectEditProfile];
    
    VAuthorizationContext context = self.isCurrentUser ? VAuthorizationContextDefault : VAuthorizationContextFollowUser;
    VAuthorizedAction *authorization = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                dependencyManager:self.dependencyManager];
    [authorization performFromViewController:self context:context completion:^(BOOL authorized)
     {
         if ( !authorized )
         {
             return;
         }
         
         if ( self.isCurrentUser )
         {
             [self performSegueWithIdentifier:@"toEditProfile" sender:self];
         }
         else
         {
             [self toggleFollowUser];
         }
     }];
}

- (void)followerHandler
{
    [self performSegueWithIdentifier:@"toFollowers" sender:self];
}

- (void)followingHandler
{
    if (self.isCurrentUser)
    {
        [self performSegueWithIdentifier:@"toHashtagsAndFollowing" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"toFollowing" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ( [segue.destinationViewController respondsToSelector:@selector(setDependencyManager:)] )
    {
        [segue.destinationViewController setDependencyManager:self.dependencyManager];
    }
}

#pragma mark - Animation

- (void)shrinkHeaderAnimated:(BOOL)animated
{
    if ( !animated )
    {
        self.currentProfileSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.profileHeaderViewController.preferredHeight);
        [self.currentProfileCell invalidateIntrinsicContentSize];
    }
    else
    {
        self.currentProfileSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.profileHeaderViewController.preferredHeight);
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
            headerCell.headerViewController = self.profileHeaderViewController;
            self.currentProfileCell = headerCell;
        }
        self.currentProfileCell.hidden = self.user == nil;
        return self.currentProfileCell;
    }
    VBaseCollectionViewCell *cell = (VBaseCollectionViewCell *)[super dataSource:dataSource cellForIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.dataSource == self.notLoggedInDataSource)
    {
        return [VNotAuthorizedProfileCollectionViewCell desiredSizeWithCollectionViewBounds:collectionView.bounds];
    }
    else if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
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

- (void)updateCollectionViewDataSource
{
    if (![[VObjectManager sharedManager] mainUserLoggedIn] && self.representsMainUser)
    {
        self.notLoggedInDataSource = [[VNotAuthorizedDataSource alloc] initWithCollectionView:self.collectionView dependencyManager:self.dependencyManager];
        self.notLoggedInDataSource.delegate = self;
        self.collectionView.dataSource = self.notLoggedInDataSource;
        [self.refreshControl removeFromSuperview];
    }
    else
    {
        self.collectionView.dataSource = self.streamDataSource;
        [self.collectionView addSubview:self.refreshControl];
    }
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
    
    [self.currentStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamItems))];
}

#pragma mark - VAbstractStreamCollectionViewController

- (void)refresh:(UIRefreshControl *)sender
{
    if (self.collectionView.dataSource == self.notLoggedInDataSource)
    {
        return;
    }
    else
    {
        [super refresh:sender];
    }
}

#pragma mark - VNotAuthorizedDataSourceDelegate

- (void)dataSourceWantsAuthorization:(VNotAuthorizedDataSource *)dataSource
{
    VLoginViewController *viewController = [VLoginViewController newWithDependencyManager:self.dependencyManager];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:[[VPresentWithBlurTransition alloc] init]];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
