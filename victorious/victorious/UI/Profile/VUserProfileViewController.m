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
#import "VConversationContainerViewController.h"
#import "VStreamItem+Fetcher.h"
#import "VConversationListViewController.h"
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
#import "VDependencyManager+VTracking.h"
#import <KVOController/FBKVOController.h>
#import "victorious-Swift.h"
#import "VSDKURLMacroReplacement.h"

@import VictoriousIOSSDK;
@import KVOController;
@import MBProgressHUD;
@import SDWebImage;

static NSString *kEditProfileSegueIdentifier = @"toEditProfile";

static const CGFloat kScrollAnimationThreshholdHeight = 75.0f;

@interface VUserProfileViewController () <VUserProfileHeaderDelegate, MBProgressHUDDelegate, VNavigationViewFloatingControllerDelegate>

@property (nonatomic, assign) BOOL didEndViewWillAppear;
@property (nonatomic, assign) BOOL isMe;

@property (nonatomic, assign) CGSize currentProfileSize;
@property (nonatomic, assign) CGFloat defaultMBProgressHUDMargin;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIViewController<VUserProfileHeader> *profileHeaderViewController;
@property (nonatomic, strong) VProfileHeaderCell *currentProfileCell;
@property (nonatomic, strong) UIButton *retryProfileLoadButton;

@property (nonatomic, strong) MBProgressHUD *retryHUD;
@property (nonatomic, strong, readwrite) VUser *user;
@property (nonatomic, strong) NSNumber *userRemoteId;

// If YES, this view controller is for the current user and is part of the main menu
@property (nonatomic, assign) BOOL representsMainUser;

@end

@implementation VUserProfileViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VUserProfileViewController *viewController = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    viewController.dependencyManager = dependencyManager; //< Set the dependencyManager before setting the profile
    [viewController addLoginStatusChangeObserver];
    
    VUser *user = [dependencyManager templateValueOfType:[VUser class] forKey:VDependencyManagerUserKey];
    NSNumber *userRemoteId = [dependencyManager templateValueOfType:[NSNumber class] forKey:VDependencyManagerUserRemoteIdKey];
    
    if ( user != nil )
    {
        viewController.user = user;
    }
    else if ( userRemoteId != nil )
    {
        viewController.dependencyManager = dependencyManager;
        viewController.userRemoteId = userRemoteId;
        viewController.representsMainUser = YES;
    }
    else
    {
        viewController.dependencyManager = dependencyManager;
        viewController.user = [VCurrentUser user];
        viewController.representsMainUser = YES;
    }
    
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

    [self initializeProfileHeader];
    
    UIColor *backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.collectionView.backgroundColor = backgroundColor;
}


- (void)initializeProfileHeader
{
    if ( self.user == nil )
    {
        return;
    }
    
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
        [self reloadUserFollowingRelationship];
    }
    
    if ( self.profileHeaderViewController != nil )
    {
        self.profileHeaderViewController.user = self.user;
        self.streamDataSource.hasHeaderCell = YES;
        [self.collectionView registerClass:[VProfileHeaderCell class]
                forCellWithReuseIdentifier:[VProfileHeaderCell preferredReuseIdentifier]];
        
        // Adding a header changes the structure of the collection view,
        // so a full reload is warranted here.
        [self.collectionView reloadData];
        self.collectionView.alwaysBounceVertical = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.streamDataSource.count > 0 )
    {
        [self shrinkHeaderAnimated:NO];
    }
    
    [self attemptToRefreshProfileUI];
    
    [self.dependencyManager configureNavigationItem:self.navigationItem];
    
    [self addAccessoryItems];
    
    self.navigationViewfloatingController.animationEnabled = YES;
    
    self.navigationItem.title = self.title;
    self.didEndViewWillAppear = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateProfileSize];
}

- (void)updateProfileSize
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
    
    [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
    
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

#pragma mark - Loading data

- (void)setInitialHeaderState
{
    if ( self.profileHeaderViewController == nil )
    {
        return;
    }
    
    if ( self.user.isCurrentUser )
    {
        self.profileHeaderViewController.state = VUserProfileHeaderStateCurrentUser;
    }
}

- (void)reloadUserFollowingRelationship
{
    FollowCountOperation *followCountOperation = [[FollowCountOperation alloc] initWithUserID:self.user.remoteId.integerValue];
    [followCountOperation queueOn:followCountOperation.defaultQueue completionBlock:^(NSError *_Nullable error)
     {
         [self updateProfileHeaderState];
     }];
}

- (void)updateProfileHeaderState
{
    if ( self.user.isCurrentUser )
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
    
    if ( [VCurrentUser user] != nil )
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

- (void)attemptToRefreshProfileUI
{
    //Ensuring viewWillAppear has finished and we have a valid profile ensures smooth profile
    // and stream presentation by avoiding unnecessary refreshes even when loading from a remoteId
    if ( !self.didEndViewWillAppear || self.user == nil )
    {
        return;
    }
    
    CGFloat height = CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length;
    height = self.streamDataSource.count ? self.profileHeaderViewController.preferredHeight : height;
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.currentProfileSize = CGSizeMake(width, height);
    
    if ( self.streamDataSource.count == 0 )
    {
        [super refresh:nil];
    }
    else
    {
        [self shrinkHeaderAnimated:YES];
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

#pragma mark -

- (void)toggleFollowUser
{
    long long userId = self.user.remoteId.longLongValue;
    NSString *sourceScreenName = VFollowSourceScreenProfile;
    
    RequestOperation *operation;
    if ( self.user.isFollowedByMainUser.boolValue )
    {
        operation = [[UnfollowUserOperation alloc] initWithUserID:userId sourceScreenName:sourceScreenName];
    }
    else
    {
        operation = [[FollowUsersOperation alloc] initWithUserID:userId sourceScreenName:sourceScreenName];
    }
    [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
     {
         self.profileHeaderViewController.loading = NO;
     }];
}

#pragma mark - Login status change

- (void)loginStateDidChange:(NSNotification *)notification
{
    [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
    
    if ( self.representsMainUser  )
    {
        if ( [VCurrentUser user] != nil )
        {
            // User logged in
            self.user = [VCurrentUser user];
            [self updateProfileHeaderState];
        }
        else
        {
            // User logged out, clear away all stream items and unload any user data
            [self.streamDataSource unloadStream];
            self.profileHeaderViewController = nil;
            self.user = nil;
        }
    }
}

- (void)setUserRemoteId:(NSNumber *)userRemoteId
{
    if ( _userRemoteId == userRemoteId )
    {
        return;
    }
    _userRemoteId = userRemoteId;
    
    UserInfoOperation *userInfoOperation = [[UserInfoOperation alloc] initWithUserID:userRemoteId.integerValue];
    [userInfoOperation queueOn:userInfoOperation.defaultQueue completionBlock:^(NSError *_Nullable error) {
        VUser *user = userInfoOperation.user;
        if ( user != nil && error == nil )
        {
            [self setUser:user];
        }
        else
        {
            VLog( @"Error loading user with remoteId %@ while presenting `VUserProfileViewController`", userRemoteId );
        }
    }];
}

- (void)setUser:(VUser *)user
{
    NSAssert(self.dependencyManager != nil, @"dependencyManager should not be nil in VUserProfileViewController when the profile is set");
    
    if ( _user != nil )
    {
        [self.KVOController unobserve:_user keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
    }
    
    if ( user == _user )
    {
        return;
    }
    
    _user = user;
    [self initializeProfileHeader];
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:_user
                        keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              [welf updateProfileHeaderState];
                          }];
    
    self.currentStream = [self createUserProfileStreamWithUserID:_user.remoteId.stringValue];
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    
    [self reloadUserFollowingRelationship];
    [self attemptToRefreshProfileUI];
    [self setupFloatingView];
}

- (VStream *)createUserProfileStreamWithUserID:(NSString *)userID
{
    NSCharacterSet *charSet = [NSCharacterSet vsdk_pathPartAllowedCharacterSet];
    NSString *escapedRemoteId = [(userID ?: @"0") stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    NSString *apiPath = [NSString stringWithFormat:@"/api/sequence/detail_list_by_user/%@/%@/%@",
                         escapedRemoteId, VSDKPaginatorMacroPageNumber, VSDKPaginatorMacroItemsPerPage];
    NSDictionary *query = @{ @"apiPath" : apiPath };
    
    id<PersistentStoreType>  persistentStore = [PersistentStoreSelector defaultPersistentStore];
    __block VStream *stream;
    [persistentStore.mainContext performBlockAndWait:^void {
        stream = (VStream *)[persistentStore.mainContext v_findOrCreateObjectWithEntityName:[VStream v_entityName]
                                                                            queryDictionary:query];
        [persistentStore.mainContext save:nil];
    }];
    return stream;
}

- (NSString *)title
{
    if ( [self isDisplayingFloatingProfileHeader] )
    {
        return nil;
    }
    else if ( !self.user.isCurrentUser )
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
    if ( self.user.isCurrentUser )
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
    if (self.user.isCurrentUser)
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
    [self updateProfileSize];
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
         [self.currentProfileCell invalidateIntrinsicContentSize];
         [self.currentProfileCell layoutIfNeeded];
         
     } completion:nil];
    
    [self.collectionView performBatchUpdates:^
     {
         [self.collectionView invalidateIntrinsicContentSize];
     } completion:nil];
    self.collectionView.alwaysBounceVertical = YES;
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
    if ([self isDisplayingFloatingProfileHeader] && self.user.isCurrentUser)
    {
        BOOL shouldHideTitle = [(VStreamNavigationViewFloatingController *)self.navigationViewfloatingController visibility] > 0.4f;
        self.navigationItem.title = shouldHideTitle ? @"" : title;
    }
    else if (self.user.isCurrentUser)
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
            self.currentProfileCell = headerCell;
        }
        
        if ( self.profileHeaderViewController != nil )
        {
            [self.profileHeaderViewController willMoveToParentViewController:self];
            self.currentProfileCell.headerViewController = self.profileHeaderViewController;
            [self.profileHeaderViewController didMoveToParentViewController:self];
        }
        
        self.currentProfileCell.hidden = self.user == nil;
        return self.currentProfileCell;
    }
    else
    {
        return [super dataSource:dataSource cellForIndexPath:indexPath];
    }
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
    return [self array:self.navigationController.viewControllers containsObjectOfClass:[VConversationListViewController class]];
}

#pragma mark - VNavigationViewFloatingControllerDelegate

- (void)floatingViewSelected:(UIView *)floatingView
{
    // Scroll to top
    [self.collectionView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    const BOOL didNavigateFromInbox = [self navigationHistoryContainsInbox];
    const BOOL isCurrentUserLoggedIn = [VCurrentUser user] != nil;
    const BOOL isCurrentUser = self.user != nil && self.user == [VCurrentUser user];
    
    if ( [menuItem.destination isKindOfClass:[VConversationContainerViewController class]] )
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
    if ( [menuItem.destination isKindOfClass:[VConversationContainerViewController class]] )
    {
        if ( self.user.isCurrentUser )
        {
            return NO;
        }
        else
        {
            // Fetch the conversation or create a new one
            VDependencyManager *destinationDependencyManager = ((VConversationContainerViewController *)menuItem.destination).dependencyManager;
            LoadUserConversationOperation *operation = [[LoadUserConversationOperation alloc] initWithUserID:self.user.remoteId.integerValue];
            [operation queueOn:operation.defaultQueue completionBlock:^(Operation *_Nonnull op)
             {
                 VConversation *conversation = operation.loadedConversation;
                 if ( conversation != nil )
                 {
                     VConversationContainerViewController *viewController = [VConversationContainerViewController newWithDependencyManager:destinationDependencyManager];
                     viewController.conversation = conversation;
                     [self.navigationController pushViewController:viewController animated:YES];
                 }
             }];
            
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

#pragma mark - VPaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [super paginatedDataSource:paginatedDataSource didUpdateVisibleItemsFrom:oldValue to:newValue];
    
    if ( self.streamDataSource.count > 0 )
    {
        [self shrinkHeaderAnimated:YES];
    }
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didReceiveError:(NSError *)error
{
    [super paginatedDataSource:paginatedDataSource didReceiveError:error];
}

@end
