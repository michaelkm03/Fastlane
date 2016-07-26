//
//  VConversationListViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VConversationListViewController.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VConversationViewController.h"
#import "VConversationContainerViewController.h"
#import "VConversationCell.h"
#import "VRootViewController.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VNavigationController.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VNavigationController.h"
#import "victorious-swift.h"

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";

@interface VConversationListViewController () <VProvidesNavigationMenuItemBadge, VCellWithProfileDelegate, VConversationContainerViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *messageViewControllers;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, strong) VConversation *queuedConversation;
@property (nonatomic, weak) UIViewController *selectedConversationViewController;

@end

static char kKVOContext;

NSString * const VConversationListViewControllerDeeplinkHostComponent = @"inbox";
NSString * const VConversationListViewControllerInboxPushReceivedNotification = @"VConversationListViewControllerInboxPushReceivedNotification";

@implementation VConversationListViewController

@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

+ (instancetype)inboxViewController
{
    return [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"inbox"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VConversationListViewController *viewController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"inbox"];
    if (viewController)
    {
        viewController.dependencyManager = dependencyManager;
        viewController.messageCountCoordinator = [[VUnreadMessageCountCoordinator alloc] init];
        [dependencyManager configureNavigationItem:viewController.navigationItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(inboxMessageNotification:) name:VConversationListViewControllerInboxPushReceivedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(applicationDidBecomeActive:) name:VApplicationDidBecomeActiveNotification object:nil];
    }
    return viewController;
}

- (void)dealloc
{
    self.messageCountCoordinator = nil; // calling property setter to remove KVO
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [[ConversationListDataSource alloc] initWithDependencyManager:self.dependencyManager];
    self.dataSource.delegate = self;
    [self.dataSource registerCells:self.tableView];
    self.tableView.dataSource = self.dataSource;

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = VConversationCellHeight;
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.noContentView = [VNoContentView viewFromNibWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = NSLocalizedString(@"NoMessagesTitle", @"");
    self.noContentView.message = NSLocalizedString(@"NoMessagesMessage", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noMessagesIcon"];
    
    // Removes the separaters for empty rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dataSource removeDeletedItems];
    
    [self.dependencyManager trackViewWillAppear:self];
    [self updateNavigationItem];

    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-CGRectGetHeight(self.navigationController.navigationBar.bounds), 0, 0, 0);
    
    const BOOL isReturningFromMessage = self.selectedConversationViewController != nil;
    if ( isReturningFromMessage )
    {
        // Any sending/receiving messages that happens while a conversation detail is shown
        // will all be cached locally, so only a local refresh is needed
        [self.dataSource refreshLocalWithCompletion:nil];
    }
    else if ( self.dataSource.visibleItems.count == 0 )
    {
        // Refresh and show refresh control since we are loading for the first time in a new session
        [self.refreshControl beginRefreshing];
        [self refresh];
    }
    
    self.selectedConversationViewController = nil;
    [self updateTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Inbox"];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
    
    self.badgeNumber = [self.messageCountCoordinator unreadMessageCount];
    
    if ( self.queuedConversation != nil )
    {
        [self showConversation:self.queuedConversation animated:YES];
        self.queuedConversation = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[VTrackingManager sharedInstance] endEvent:@"Inbox"];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)refresh
{
    [self.dataSource loadConversations:VPageTypeFirst completion:^(NSError *_Nullable error)
     {
         [self.refreshControl endRefreshing];
         [self updateTableView];
         [self.messageCountCoordinator updateUnreadMessageCount];
         [self updateBadges];
         [self.dataSource redecorateVisibleCells:self.tableView];
     }];
}

#pragma mark - Properties

- (void)updateNavigationItem
{
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)setMessageCountCoordinator:(VUnreadMessageCountCoordinator *)messageCountCoordinator
{
    if (_messageCountCoordinator)
    {
        [_messageCountCoordinator removeObserver:self forKeyPath:NSStringFromSelector(@selector(unreadMessageCount))];
    }
    _messageCountCoordinator = messageCountCoordinator;
    
    if (messageCountCoordinator)
    {
        [messageCountCoordinator addObserver:self forKeyPath:NSStringFromSelector(@selector(unreadMessageCount)) options:NSKeyValueObservingOptionNew context:&kKVOContext];
        
        if ( [VCurrentUser user] != nil )
        {
            [messageCountCoordinator updateUnreadMessageCount];
            [self updateBadges];
        }
    }
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    
    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock( badgeNumber );
    }
    [self updateBadge];
}

#pragma mark - VAuthorizationContextProvider

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextInbox;
}

#pragma mark - VConversationContainerViewControllerDelegate

- (void)onConversationFlagged:(VConversation *)conversation
{
    [self removeCachedViewControllerForUserId:conversation.user.remoteId];
}

- (void)onConversationUpdated:(VConversation *)conversation
{
    [self.dataSource redecorateVisibleCells:self.tableView];
}

#pragma mark - Message View Controller Cache

- (VConversationContainerViewController *)messageViewControllerForUser:(VUser *)user
{
    NSAssert([NSThread isMainThread], @"This method should be called from the main thread only");
    
    if ( self.messageViewControllers == nil )
    {
        self.messageViewControllers = [[NSMutableDictionary alloc] init];
    }
    VConversationContainerViewController *messageViewController = self.messageViewControllers[ user.remoteId];
    
    if ( messageViewController == nil )
    {
        NSString *title = NSLocalizedString( @"More", @"" );
        NSString *imageName = @"OverFlowIcon";
        NSDictionary *moreAcessory = @{ VDependencyManagerDestinationKey: [NSNull null],
                                        VDependencyManagerTitleKey: title,
                                        VDependencyManagerIconKey: [UIImage imageNamed:imageName],
                                        VDependencyManagerIdentifierKey: VDependencyManagerAccessoryItemMore,
                                        VDependencyManagerPositionKey: VDependencyManagerPositionRight };
        NSDictionary *childConfiguration = @{ VDependencyManagerAccessoryScreensKey : @[ moreAcessory ] };
        VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
        messageViewController = [VConversationContainerViewController newWithDependencyManager:childDependencyManager];
        messageViewController.delegate = self;
        self.messageViewControllers[ user.remoteId ] = messageViewController;
    }
    
    return messageViewController;
}

- (void)removeAllCachedViewControllers
{
    [self.messageViewControllers removeAllObjects];
}

- (void)removeCachedViewControllerForUserId:(NSNumber *)userRemoteId
{
    if ( self.messageViewControllers == nil || userRemoteId == nil )
    {
        return;
    }
    [self.messageViewControllers removeObjectForKey:userRemoteId];
}

- (void)deleteConversationAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = (VConversation *)self.dataSource.visibleItems[ indexPath.row ];
    NSNumber *userRemoteId = conversation.user.remoteId;
    ConversationDeleteOperation *operation = [[ConversationDeleteOperation alloc] initWithUserRemoteID:userRemoteId.integerValue];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         self.shouldAnimateDataSourceChanges = YES;
         [self.dataSource removeDeletedItems];
         [self removeCachedViewControllerForUserId:userRemoteId];
         [self updateBadges];
     }];
}

#pragma mark - UITableViewDelegate

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                           editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:NSLocalizedString(@"Delete", nil)
                                                                          handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath)
                                          {
                                              [self deleteConversationAtIndexPath:indexPath];
                                          }];
    return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell isKindOfClass:[VConversationCell class]] )
    {
        VConversationCell *conversationCell = (VConversationCell *)cell;
        conversationCell.delegate = self;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = self.dataSource.visibleItems[ indexPath.row ];
    if (conversation.user)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMessage];
        [self showConversation:conversation animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Actions

- (void)showConversation:(VConversation *)conversation animated:(BOOL)animated
{
    NSParameterAssert(conversation != nil);
    VConversationContainerViewController *detailVC = [self messageViewControllerForUser:conversation.user];
    detailVC.conversation = conversation;
    UINavigationController *rootInnerNavigationController = [self rootNavigationController].innerNavigationController;
    
    if ( self.navigationController == nil )
    {
        self.queuedConversation = conversation;
    }
    else
    {
        [self.messageCountCoordinator markConversationRead:conversation completion:^
         {
             [self.dataSource redecorateVisibleCells:self.tableView];
         }];
        
        if ( [rootInnerNavigationController.viewControllers containsObject:detailVC] )
        {
            if ( rootInnerNavigationController.topViewController != detailVC )
            {
                [rootInnerNavigationController popToViewController:detailVC animated:animated];
            }
        }
        else
        {
            detailVC.messageCountCoordinator = self.messageCountCoordinator;
            [rootInnerNavigationController pushViewController:detailVC animated:YES];
        }
        
        self.selectedConversationViewController = detailVC;
    }
}

- (IBAction)refresh:(UIRefreshControl *)refreshControl
{
    [self refresh];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.destination isKindOfClass:[VConversationContainerViewController class]] )
    {
        [self showSearch];
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    return YES;
}

#pragma mark - Pagination

- (void)shouldLoadNextPage
{
    if ( [self.dataSource isLoading] )
    {
        return;
    }
    
    self.shouldAnimateDataSourceChanges = NO;
    [self.dataSource loadConversations:VPageTypeNext completion:^(NSError *error){
        self.shouldAnimateDataSourceChanges = YES;
    }];
}

#pragma mark - NSNotification handlers

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ( [VCurrentUser user] != nil )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
}

- (void)loggedInChanged:(NSNotification *)notification
{
    if ( [VCurrentUser user] != nil )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
    else
    {
        [self.dataSource unload];
        self.badgeNumber = 0;
    }
}

- (void)inboxMessageNotification:(NSNotification *)notification
{
    [self.dataSource refreshRemote:^(NSArray *array, NSError *error, BOOL cancelled)
     {
         [self.messageCountCoordinator updateUnreadMessageCount];
         [self updateBadges];
         [self.dataSource redecorateVisibleCells:self.tableView];
    }];
}

- (void)updateBadges
{
    self.badgeNumber = self.messageCountCoordinator.unreadMessageCount;
    [self updateBadge];
}

- (void)updateBadge
{
    // Removed due to removeal of VBadgeResponder
}

#pragma mark - Key-Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context != &kKVOContext )
    {
        return;
    }
    
    if ( object == self.messageCountCoordinator && [keyPath isEqualToString:NSStringFromSelector(@selector(unreadMessageCount))] )
    {
        NSNumber *newUnreadCount = change[NSKeyValueChangeNewKey];
        
        if ( [newUnreadCount isKindOfClass:[NSNumber class]] )
        {
            self.badgeNumber = [newUnreadCount integerValue];
        }
    }
}

#pragma mark - VNavigationDestination

- (BOOL)shouldNavigate
{
    return YES;
}

#pragma mark - VCellWithProfileDelegate

- (void)cellDidSelectProfile:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ( indexPath == nil )
    {
        return;
    }
    
    VConversation *conversation = [self.dataSource.visibleItems objectAtIndex:indexPath.row];
    UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerFor:conversation.user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
