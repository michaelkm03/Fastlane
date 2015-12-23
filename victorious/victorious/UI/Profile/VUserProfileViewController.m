//
//  VUserProfileViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserProfileViewController.h"
#import "VUser.h"
#import "VProfileEditViewController.h"
#import "VMessageContainerViewController.h"
#import "VStream+Fetcher.h"
#import "VInboxViewController.h"
#import "VProfileHeaderCell.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VFindFriendsViewController.h"
#import "VDependencyManager.h"
#import "VBaseCollectionViewCell.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"
#import "VUserProfileHeader.h"
#import "VDependencyManager+VUserProfile.h"
#import "VStreamNavigationViewFloatingController.h"
#import "VNavigationController.h"
#import "VBarButton.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VProfileDeeplinkHandler.h"
#import "VInboxDeepLinkHandler.h"
#import "VFloatingUserProfileHeaderViewController.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VUsersViewController.h"
#import "VFollowersDataSource.h"
#import "VUserIsFollowingDataSource.h"
#import "VDependencyManager+VTracking.h"
#import "VFollowResponder.h"
#import <KVOController/FBKVOController.h>
#import "victorious-Swift.h"

@import VictoriousIOSSDK;
@import KVOController;
@import MBProgressHUD;
@import SDWebImage;

static void * VUserProfileViewContext = &VUserProfileViewContext;
static void * VUserProfileAttributesContext =  &VUserProfileAttributesContext;

static NSString *kEditProfileSegueIdentifier = @"toEditProfile";

// According to MBProgressHUD.h, a 37 x 37 square is the best fit for a custom view within a MBProgressHUD
static const CGFloat MBProgressHUDCustomViewSide = 37.0f;

static const CGFloat kScrollAnimationThreshholdHeight = 75.0f;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, MBProgressHUDDelegate, VNavigationViewFloatingControllerDelegate, VFollowResponder>

@property (nonatomic, assign) BOOL didEndViewWillAppear;
@property (nonatomic, assign) BOOL isMe;

@property (nonatomic, assign) CGSize currentProfileSize;
@property (nonatomic, assign) CGFloat defaultMBProgressHUDMargin;
@property (nonatomic, strong) NSNumber *remoteId;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIViewController<VUserProfileHeader> *profileHeaderViewController;
@property (nonatomic, strong) VProfileHeaderCell *currentProfileCell;
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
    
    VUser *mainUser = [VUser currentUser];
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
    
    VUserProfileViewController *viewController = [self userProfileWithUser:[VUser currentUser] andDependencyManager:dependencyManager];
    viewController.representsMainUser = YES;
    return viewController;
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
    [self loadPage:VPageTypeFirst completion:nil];
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = backgroundColor;
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
        else
        {
            [self reloadUserFollowCounts];
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
        [self showRefreshHUD];
        [self loadUserWithRemoteId:self.remoteId forceReload:NO];
    }
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.view.backgroundColor = backgroundColor;
    
    if ( self.streamDataSource.count != 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
    
    self.didEndViewWillAppear = YES;
    [self attemptToRefreshProfileUI];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self addAccessoryItems];
    
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
    
    [self addBadgingToAccessoryItems];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueUserProfile forSessionParameterWithKey:VTrackingKeyContext];
    
    [self setupFloatingView];
    
    // Hide title if necessary
    [self updateTitleVisibilityWithVerticalOffset:self.collectionView.contentOffset.y];
}

- (void)updateAccessoryItems
{
    [self addAccessoryItems];
    [self addBadgingToAccessoryItems];
}

- (void)addAccessoryItems
{
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)addBadgingToAccessoryItems
{
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
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
        self.navigationViewfloatingController = [[VStreamNavigationViewFloatingController alloc] initWithFloatingView:floatingView
                                                                                         floatingParentViewController:parent
                                                                                         verticalScrollThresholdStart:[self floatingHeaderAnimationThresholdStart]
                                                                                           verticalScrollThresholdEnd:[self floatingHeaderAnimationThresholdEnd]];
        self.navigationViewfloatingController.delegate = self;
        self.navigationViewfloatingController.animationEnabled = YES;
        self.navigationBarShouldAutoHide = NO;
        self.navigationItem.title = self.title;
    }
}

- (CGFloat)floatingHeaderAnimationThresholdStart
{
    const CGFloat middle = CGRectGetMidY(self.profileHeaderViewController.view.bounds);
    const CGFloat thresholdStart = middle - kScrollAnimationThreshholdHeight * 0.5f;
    return thresholdStart;
}

- (CGFloat)floatingHeaderAnimationThresholdEnd
{
    const CGFloat middle = CGRectGetMidY(self.profileHeaderViewController.view.bounds);
    const CGFloat thresholdEnd = middle + kScrollAnimationThreshholdHeight * 0.5f;
    return thresholdEnd;
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
    const VUser *loggedInUser = [VUser currentUser];
    return loggedInUser != nil && [self.user.remoteId isEqualToNumber:loggedInUser.remoteId];
}

#pragma mark - Loading data

- (void)reloadUserFollowCounts
{
#warning FIXME:
    //[[VObjectManager sharedManager] countOfFollowsForUser:self.user successBlock:nil failBlock:nil];
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
}

- (void)reloadUserFollowingRelationship
{
    if ( self.isCurrentUser )
    {
        self.profileHeaderViewController.state = VUserProfileHeaderStateCurrentUser;
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
    
    if ( [VUser currentUser] != nil )
    {
        header.state = self.user.isFollowedByMainUser.boolValue ? VUserProfileHeaderStateFollowingUser : VUserProfileHeaderStateNotFollowingUser;
    }
    else
    {
        header.state = VUserProfileHeaderStateNotFollowingUser;
    }
}

- (void)showRefreshHUD
{
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
}

- (void)loadUserWithRemoteId:(NSNumber *)remoteId forceReload:(BOOL)forceReload
{
    self.remoteId = remoteId;
    
    [self fetchUserInfoWithUserID:remoteId.integerValue completion:^(NSError *_Nullable error) {
        if ( error != nil )
        {
            //Handle profile load failure by changing navigationItem title and showing a retry button in the indicator
            self.navigationItem.title = NSLocalizedString(@"Profile load failed!", @"");
            self.retryHUD.mode = MBProgressHUDModeCustomView;
            self.retryHUD.customView = self.retryProfileLoadButton;
            self.retryHUD.margin = 0.0f;
            [self.retryProfileLoadButton setUserInteractionEnabled:YES];
        }
        else
        {
            [self.retryHUD hide:YES];
            [self.retryProfileLoadButton removeFromSuperview];
            self.retryHUD = nil;
            
            // Reload follow counts when user pulls to refresh
            [self reloadUserFollowCounts];
        }
    }];
}

- (void)retryProfileLoad
{
    //Disable user interaction to avoid spamming
    [self.retryProfileLoadButton setUserInteractionEnabled:NO];
    [self showRefreshHUD];
    [self loadUserWithRemoteId:self.remoteId forceReload:NO];
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
        
        if ( self.streamDataSource.count == 0 )
        {
            [self refresh:nil];
        }
        else
        {
            [self shrinkHeaderAnimated:YES];
            [self reloadUserFollowingRelationship];
        }
    }
}

#pragma mark - Superclass Overrides

- (void)loadPage:(VPageType)pageType completion:(void (^)(void))completionBlock
{
    if ( self.user == nil )
    {
        return;
    }
    [super loadPage:pageType completion:completionBlock];
}

- (void)didFinishLoadingWithPageType:(VPageType)pageType
{
    if ( self.streamDataSource.count > 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
    [self.profileHeaderViewController reloadProfileImage];
    [self reloadUserFollowingRelationship];
}

#pragma mark -

- (void)toggleFollowUser
{
    if ( self.profileHeaderViewController.state == VUserProfileHeaderStateFollowingUser )
    {
        self.profileHeaderViewController.loading = YES;
        
        [self unfollowUser:self.user withAuthorizedBlock:nil andCompletion:^(VUser *userActedOn)
        {
            self.profileHeaderViewController.loading = NO;
            [self reloadUserFollowingRelationship];
        }
        fromViewController:self
            withScreenName:nil
         ];
    }
    else if ( self.profileHeaderViewController.state == VUserProfileHeaderStateNotFollowingUser )
    {
        [self stopObservingUserProfile];
        self.profileHeaderViewController.loading = YES;
        
        [self followUser:self.user
     withAuthorizedBlock:nil
           andCompletion:^(VUser *userActedOn)
        {
            self.profileHeaderViewController.loading = NO;
            [self reloadUserFollowingRelationship];
        }
      fromViewController:self
          withScreenName:nil
         ];
    }
}

#pragma mark - Login status change

- (void)loginStateDidChange:(NSNotification *)notification
{
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
    
    if ( self.representsMainUser )
    {
        self.user = [VUser currentUser];
    }
    else if ( [VUser currentUser] != nil )
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
    [self.KVOController observe:_user keyPath:NSStringFromSelector(@selector(isFollowedByMainUser)) options:NSKeyValueObservingOptionNew context:VUserProfileAttributesContext];
    
    NSCharacterSet *charSet = [NSCharacterSet vsdk_pathPartCharacterSet];
    NSString *escapedRemoteId = [(user.remoteId.stringValue ?: @"0") stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    NSString *apiPath = [NSString stringWithFormat:@"/api/sequence/detail_list_by_user/%@/%@/%@",
                         escapedRemoteId, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    NSDictionary *query = @{ @"apiPath" : apiPath };
    
    id<PersistentStoreType>  persistentStore = [[MainPersistentStore alloc] init];
    [persistentStore.mainContext performBlockAndWait:^void {
        self.currentStream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream entityName] queryDictionary:query];
        [persistentStore.mainContext save:nil];
    }];
    
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
    else if ( !self.isCurrentUser )
    {
        return self.user.name;
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
    if ( self.isCurrentUser )
    {
        [self performSegueWithIdentifier:kEditProfileSegueIdentifier sender:self];
    }
    else
    {
        [self toggleFollowUser];
    }
}

- (void)followerHandler
{
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{}];
    VUsersViewController *usersViewController = [[VUsersViewController alloc] initWithDependencyManager:childDependencyManager];
    usersViewController.title = NSLocalizedString( @"followers", nil );
    usersViewController.usersDataSource = [[VFollowersDataSource alloc] initWithUser:self.user];
    usersViewController.usersViewContext = VUsersViewContextFollowers;
    
    [self.navigationController pushViewController:usersViewController animated:YES];
}

- (void)followingHandler
{
    if (self.isCurrentUser)
    {
        [self performSegueWithIdentifier:@"toHashtagsAndFollowing" sender:self];
    }
    else
    {
        VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{}];
        VUsersViewController *usersViewController = [[VUsersViewController alloc] initWithDependencyManager:childDependencyManager];
        usersViewController.title = NSLocalizedString( @"Following", nil );
        usersViewController.usersDataSource = [[VUserIsFollowingDataSource alloc] initWithUser:self.user];
        usersViewController.usersViewContext = VUsersViewContextFollowing;
        [self.navigationController pushViewController:usersViewController animated:YES];
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
    if ( [segue.destinationViewController isKindOfClass:[VAbstractProfileEditViewController class]])
    {
        VAbstractProfileEditViewController *editVC = (VAbstractProfileEditViewController *)segue.destinationViewController;
        editVC.profile = self.user;
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

#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    // Hide title if necessary
    [self updateTitleVisibilityWithVerticalOffset:scrollView.contentOffset.y];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Hide title if necessary
    [self updateTitleVisibilityWithVerticalOffset:scrollView.contentOffset.y];
}

- (void)updateTitleVisibilityWithVerticalOffset:(CGFloat)verticalOffset
{
    NSString *title = [self.dependencyManager stringForKey:VDependencyManagerTitleKey];
    if ([self isDisplayingFloatingProfileHeader] && [self isCurrentUser])
    {
        BOOL shouldHideTitle = [(VStreamNavigationViewFloatingController *)self.navigationViewfloatingController visibility] > 0.4f;
        self.navigationItem.title = shouldHideTitle ? @"" : title;
    }
    else if ([self isCurrentUser])
    {
        self.navigationItem.title = title;
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
    if (self.streamDataSource.hasHeaderCell && indexPath.section == 0)
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
    if (context == VUserProfileAttributesContext && [keyPath isEqualToString:NSStringFromSelector(@selector(isFollowedByMainUser))] && !self.representsMainUser)
    {
        [self reloadUserFollowingRelationship];
        [self reloadUserFollowCounts];
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
    NSNumber *mainUserId = [VUser currentUser].remoteId;
    const BOOL hasUserData = self.representsMainUser && mainUserId != nil;
    const BOOL wasTriggeredByUIElement = sender != nil;
    if ( wasTriggeredByUIElement && hasUserData )
    {
        [self loadUserWithRemoteId:mainUserId forceReload:YES];
    }
    
    [super refresh:sender];
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
    [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    const BOOL didNavigateFromInbox = [self navigationHistoryContainsInbox];
    const BOOL isCurrentUserLoggedIn = [VUser currentUser] != nil;
    const BOOL isCurrentUser = self.user != nil && self.user == [VUser currentUser];
    
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
    else
    {
        return [super shouldDisplayAccessoryMenuItem:menuItem fromSource:source];
    }
}

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    const BOOL isCurrentUser = self.user != nil && self.user == [VUser currentUser];
    
    if ( [menuItem.destination isKindOfClass:[VMessageContainerViewController class]] )
    {
        if ( isCurrentUser )
        {
            return NO;
        }
        else
        {
            // Make a new container with destination's dependencyManager, and push it to the navigation controller stack
            VDependencyManager *destinationDependencyManager = ((VMessageContainerViewController *)menuItem.destination).dependencyManager;
            VMessageContainerViewController *destinationMessageContainerVC = [VMessageContainerViewController messageViewControllerForUser:self.user dependencyManager: destinationDependencyManager];
            [self.navigationController pushViewController:destinationMessageContainerVC animated:YES];
            
            return NO;
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

#pragma mark - VDeepLinkSupporter

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    return [[VProfileDeeplinkHandler alloc] initWithDependencyManager:self.dependencyManager];
}

#pragma mark - VTabMenuContainedViewControllerNavigation

- (void)reselected
{
    [self floatingViewSelected:nil];
}

#pragma mark - VFollowResponder

- (void)followUser:(VUser *)user
withAuthorizedBlock:(void (^)(void))authorizedBlock
     andCompletion:(VFollowEventCompletion)completion
fromViewController:(UIViewController *)viewControllerToPresentOn
    withScreenName:(NSString *)screenName
{
    NSString *sourceScreen = screenName?:VFollowSourceScreenProfile;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(followUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder followUser:user
            withAuthorizedBlock:authorizedBlock
                  andCompletion:completion
             fromViewController:self
                 withScreenName:sourceScreen];
}

- (void)unfollowUser:(VUser *)user 
 withAuthorizedBlock:(void (^)(void))authorizedBlock
       andCompletion:(VFollowEventCompletion)completion
  fromViewController:(UIViewController *)viewControllerToPresentOn
      withScreenName:(NSString *)screenName
{
    NSString *sourceScreen = screenName?:VFollowSourceScreenProfile;
    id<VFollowResponder> followResponder = [[self nextResponder] targetForAction:@selector(unfollowUser:withAuthorizedBlock:andCompletion:fromViewController:withScreenName:)
                                                                      withSender:nil];
    NSAssert(followResponder != nil, @"%@ needs a VFollowingResponder higher up the chain to communicate following commands with.", NSStringFromClass(self.class));
    
    [followResponder unfollowUser:user
              withAuthorizedBlock:authorizedBlock
                    andCompletion:completion
               fromViewController:self
                   withScreenName:sourceScreen];
}

@end
