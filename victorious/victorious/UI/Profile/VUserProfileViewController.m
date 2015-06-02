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
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VFindFriendsViewController.h"
#import "VDependencyManager.h"
#import "VBaseCollectionViewCell.h"
#import "VDependencyManager+VScaffoldViewController.h"
#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"
#import "VUserProfileHeader.h"
#import "VDependencyManager+VUserProfile.h"
#import "VStreamNavigationViewFloatingController.h"
#import "VNavigationController.h"
#import "VBarButton.h"
#import "VAuthorizedAction.h"

static void * VUserProfileViewContext = &VUserProfileViewContext;
static void * VUserProfileAttributesContext =  &VUserProfileAttributesContext;

static NSString *kEditProfileSegueIdentifier = @"toEditProfile";

// According to MBProgressHUD.h, a 37 x 37 square is the best fit for a custom view within a MBProgressHUD
static const CGFloat MBProgressHUDCustomViewSide = 37.0f;

static const CGFloat kScrollAnimationThreshholdHeight = 75.0f;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, MBProgressHUDDelegate, VNotAuthorizedDataSourceDelegate, VNavigationViewFloatingControllerDelegate>

@property (nonatomic, assign) BOOL didEndViewWillAppear;
@property (nonatomic, assign) BOOL isMe;

@property (nonatomic, assign) CGSize currentProfileSize;
@property (nonatomic, assign) CGFloat defaultMBProgressHUDMargin;
@property (nonatomic, strong) NSNumber *remoteId;
@property (nonatomic, strong) UIImageView *backgroundImageView;

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
    [viewController addLoginStatusChangeObserver];
    
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
    [viewController addLoginStatusChangeObserver];
    
    viewController.user = aUser;
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoggedInChangedNotification object:nil];
}

- (void)addLoginStatusChangeObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateDidChange:)
                                                 name:kLoggedInChangedNotification object:nil];
}

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateProfileHeader];
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = backgroundColor;
    
    [self.KVOController observe:self.currentStream
                        keyPath:@"sequences"
                        options:NSKeyValueObservingOptionNew
                        context:VUserProfileViewContext];
    [self updateCollectionViewDataSource];
}

- (void)updateProfileHeader
{
    if ( self.user != nil )
    {
        if ( self.profileHeaderViewController == nil )
        {
            self.profileHeaderViewController = [self.dependencyManager userProfileHeaderWithUser:self.user];
            if ( self.profileHeaderViewController != nil )
            {
                self.profileHeaderViewController.delegate = self;
                [self setInitialHeaderState];
            }
        }
        
        BOOL hasHeader = self.profileHeaderViewController != nil;
        if ( hasHeader )
        {
            [self.collectionView registerClass:[VProfileHeaderCell class]
                    forCellWithReuseIdentifier:[VProfileHeaderCell preferredReuseIdentifier]];
        }
        
        self.streamDataSource.hasHeaderCell = hasHeader;
        self.profileHeaderViewController.user = self.user;
        self.collectionView.alwaysBounceVertical = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( !self.isCurrentUser && self.user == nil && self.remoteId != nil )
    {
        [self loadUserWithRemoteId:self.remoteId];
    }
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.view.backgroundColor = backgroundColor;
    
    if ( self.streamDataSource.count != 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
    
    self.didEndViewWillAppear = YES;
    [self attemptToRefreshProfileUI];
    
    self.navigationViewfloatingController.animationEnabled = YES;
    
    self.navigationItem.title = self.title;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueUserProfile forSessionParameterWithKey:VTrackingKeyContext];
    
    [self setupFloatingView];
    
    [self updateAccessoryItems];
}

- (void)updateAccessoryItems
{
    [self.dependencyManager configureNavigationItem:self.navigationItem forViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    
    self.navigationViewfloatingController.animationEnabled = NO;
}

- (void)setupFloatingView
{
    UIViewController *parent = [self v_navigationController];
    if ( parent != nil && [self isDisplayingFloatingProfileHeader] && self.navigationViewfloatingController == nil )
    {
        UIView *floatingView = self.profileHeaderViewController.floatingProfileImage;
        const CGFloat middle = CGRectGetMidY(self.profileHeaderViewController.view.bounds);
        const CGFloat thresholdStart = middle - kScrollAnimationThreshholdHeight * 0.5f;
        const CGFloat thresholdEnd = middle + kScrollAnimationThreshholdHeight * 0.5f;
        self.navigationViewfloatingController = [[VStreamNavigationViewFloatingController alloc] initWithFloatingView:floatingView
                                                                                         floatingParentViewController:parent
                                                                                         verticalScrollThresholdStart:thresholdStart
                                                                                           verticalScrollThresholdEnd:thresholdEnd];
        self.navigationViewfloatingController.delegate = self;
        self.navigationViewfloatingController.animationEnabled = YES;
        self.navigationBarShouldAutoHide = NO;
        self.navigationItem.title = self.title;
    }
}

#pragma mark -

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
    
    [self reloadUserFollowCounts];
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
    
    if ( header.isLoading )
    {
        return;
    }
    
    if ([VObjectManager sharedManager].mainUser)
    {
        header.loading = YES;
        [[VObjectManager sharedManager] isUser:[VObjectManager sharedManager].mainUser
                                     following:self.user
                                  successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
         {
             header.loading = NO;
             const BOOL isFollowingUser = [resultObjects.firstObject boolValue];
             header.state = isFollowingUser ? VUserProfileHeaderStateFollowingUser : VUserProfileHeaderStateNotFollowingUser;
         }
                                     failBlock:^(NSOperation *operation, NSError *error)
         {
             header.loading = NO;
         }];
    }
    else
    {
        header.state = VUserProfileHeaderStateNotFollowingUser;
    }
}

- (void)loadUserWithRemoteId:(NSNumber *)remoteId
{
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
}

- (void)toggleFollowUser
{
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        self.profileHeaderViewController.loading = NO;
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"UnfollowError", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
    };
    
    if ( self.profileHeaderViewController.state == VUserProfileHeaderStateFollowingUser )
    {
        self.profileHeaderViewController.loading = YES;
        [[VObjectManager sharedManager] unfollowUser:self.user
                                        successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             self.profileHeaderViewController.loading = NO;
             self.profileHeaderViewController.state = VUserProfileHeaderStateNotFollowingUser;
         }
                                           failBlock:fail];
    }
    else if ( self.profileHeaderViewController.state == VUserProfileHeaderStateNotFollowingUser )
    {
        [self stopObservingUserProfile];
        self.profileHeaderViewController.loading = YES;
        [[VObjectManager sharedManager] followUser:self.user
                                      successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             self.profileHeaderViewController.loading = NO;
             self.profileHeaderViewController.state = VUserProfileHeaderStateFollowingUser;
         }
                                         failBlock:fail];
    }
}

#pragma mark - Login status change

- (void)loginStateDidChange:(NSNotification *)notification
{
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    
    if ( self.representsMainUser )
    {
        self.user = [VObjectManager sharedManager].mainUser;
        [self updateCollectionViewDataSource];
    }
    else if ( [VObjectManager sharedManager].authorized )
    {
        [self reloadUserFollowingRelationship];
    }
}

- (void)setUser:(VUser *)user
{
    NSAssert(self.dependencyManager != nil, @"dependencyManager should not be nil in VUserProfileViewController when the profile is set");
    
    if ( user == _user )
    {
        return;
    }
    
    [self stopObservingUserProfile];
    
    _user = user;
    
    [self.KVOController observe:_user keyPath:NSStringFromSelector(@selector(name)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_user keyPath:NSStringFromSelector(@selector(location)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_user keyPath:NSStringFromSelector(@selector(tagline)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    [self.KVOController observe:_user keyPath:NSStringFromSelector(@selector(pictureUrl)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    
    self.currentStream = [VStream streamForUser:self.user];
    
    NSString *profileName = user.name ?: @"Profile";
    
    self.title = self.isCurrentUser ? nil : profileName;
    
    [self updateProfileHeader];
    
    [self attemptToRefreshProfileUI];
    
    [self setupFloatingView];
}

- (NSString *)title
{
    if ( [self isDisplayingFloatingProfileHeader] )
    {
        return nil;
    }
    return [super title];
}

- (BOOL)isDisplayingFloatingProfileHeader
{
    return self.profileHeaderViewController.floatingProfileImage != nil;
}

#pragma mark - VUserProfileHeaderDelegate

- (UIView *)detachedViewParentView
{
    return self.navigationController.view;
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
             [self performSegueWithIdentifier:kEditProfileSegueIdentifier sender:self];
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
            NSString *identifier = [VProfileHeaderCell preferredReuseIdentifier];
            VProfileHeaderCell *headerCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            [self.profileHeaderViewController willMoveToParentViewController:self];
            headerCell.headerViewController = self.profileHeaderViewController;
            self.currentProfileCell = headerCell;
            [self.profileHeaderViewController didMoveToParentViewController:self];
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
    BOOL isNoContentCell = [[collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[VNotAuthorizedProfileCollectionViewCell class]];
    if ( ( self.streamDataSource.hasHeaderCell && indexPath.section == 0 ) || isNoContentCell )
    {
        return;
    }
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

- (void)updateCollectionViewDataSource
{
    if ( ![[VObjectManager sharedManager] mainUserLoggedIn] && self.representsMainUser )
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

- (BOOL)array:(NSArray *)array containsObjectOfClass:(Class)objectClass
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
    {
        if ( [evaluatedObject conformsToProtocol:@protocol(VMultipleContainer)] )
        {
            id<VMultipleContainer> multipleContainer = evaluatedObject;
            return [self array:multipleContainer.children containsObjectOfClass:objectClass];
        }
        return [evaluatedObject isKindOfClass:objectClass];
    }];
    return [array filteredArrayUsingPredicate:predicate].count > 0;
}

- (BOOL)navigationHistoryContainsInbox
{
    return [self array:self.navigationController.viewControllers containsObjectOfClass:[VInboxViewController class]];
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
    VAuthorizedAction *authorizationAction = [[VAuthorizedAction alloc] initWithObjectManager:[VObjectManager sharedManager]
                                                                            dependencyManager:self.dependencyManager];
    [authorizationAction performFromViewController:self
                                           context:VAuthorizationContextUserProfile
                                        completion:^(BOOL authorized) { }];
}

#pragma mark - VNavigationViewFloatingControllerDelegate

- (void)floatingViewSelected:(UIView *)floatingView
{
    // Scroll to top
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

- (void)stopObservingUserProfile
{
    [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(name))];
    [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(location))];
    [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(tagline))];
    [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(pictureUrl))];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    const BOOL didNavigateFromInbox = [self navigationHistoryContainsInbox];
    const BOOL isCurrentUserLoggedIn = [VObjectManager sharedManager].authorized;
    const BOOL isCurrentUser = self.user != nil && self.user == [VObjectManager sharedManager].mainUser;
    
    if ( [menuItem.destination isKindOfClass:[VMessageContainerViewController class]] )
    {
        if ( didNavigateFromInbox )
        {
            return NO;
        }
        else if ( isCurrentUser )
        {
            return NO;
        }
        else
        {
            if ( isCurrentUserLoggedIn )
            {
                return !self.user.isDirectMessagingDisabled.boolValue;
            }
            else
            {
                return NO;
            }
        }
    }
    else if ( [menuItem.destination isKindOfClass:[VFindFriendsViewController class]] )
    {
        return isCurrentUser;
    }
    return YES;
}

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    const BOOL isCurrentUser = self.user != nil && self.user == [VObjectManager sharedManager].mainUser;
    
    if ( [menuItem.destination isKindOfClass:[VMessageContainerViewController class]] )
    {
        if ( isCurrentUser )
        {
            return NO;
        }
        else
        {
            ((VMessageContainerViewController *)menuItem.destination).otherUser = self.user;
        }
    }
    else if ( [menuItem.destination isKindOfClass:[VFindFriendsViewController class]] )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectFindFriends];
    }
    
    return YES;
}

#pragma mark - VProvidesNavigationMenuItemBadge

@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

@end
