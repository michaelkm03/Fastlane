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
#import "VConversation+RestKit.h"
#import "VConversationViewController.h"
#import "VConversationContainerViewController.h"
#import "VConversationCell.h"
#import "VRootViewController.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUser.h"
#import "VInboxDeeplinkHandler.h"
#import "VNavigationController.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VTracking.h"
#import "VBadgeResponder.h"
#import "UIViewController+VAccessoryScreens.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "UIViewController+VRootNavigationController.h"
#import "VNavigationController.h"
#import "victorious-swift.h"

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";

@interface VConversationListViewController () <VProvidesNavigationMenuItemBadge, VScrollPaginatorDelegate, VCellWithProfileDelegate>

@property (strong, nonatomic) NSMutableDictionary *messageViewControllers;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, strong) VUser *userWithQueuedConversation;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;

@end

static char kKVOContext;

NSString * const VConversationListViewControllerDeeplinkHostComponent = @"inbox";
NSString * const VConversationListViewControllerInboxPushReceivedNotification = @"VInboxContainerViewControllerInboxPushReceivedNotification";

@implementation VConversationListViewController

@synthesize multipleContainerChildDelegate = _multipleContainerChildDelegate;
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
        viewController.messageCountCoordinator = [[VUnreadMessageCountCoordinator alloc] initWithObjectManager:[dependencyManager objectManager]];
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

#pragma mark -  Container Child

- (void)multipleContainerDidSetSelected:(BOOL)isDefault
{
    // Empty
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    self.dataSource = [[ConversationListDataSource alloc] initWithDependencyManager:self.dependencyManager];
    [self.dataSource registerCells:self.tableView];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = VConversationCellHeight;
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.noContentView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = NSLocalizedString(@"NoMessagesTitle", @"");
    self.noContentView.message = NSLocalizedString(@"NoMessagesMessage", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noMessagesIcon"];
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    [self updateNavigationItem];
    [self.tableView setContentOffset:CGPointZero];

    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-CGRectGetHeight(self.navigationController.navigationBar.bounds), 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Inbox"];
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
    
    self.badgeNumber = [self.messageCountCoordinator unreadMessageCount];
    
    if ( self.userWithQueuedConversation != nil )
    {
#warning FIXME
        //[self displayConversationForUser:self.userWithQueuedConversation animated:YES];
        self.userWithQueuedConversation = nil;
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
        
        if ( [self.dependencyManager.objectManager mainUserLoggedIn] )
        {
            [messageCountCoordinator updateUnreadMessageCount];
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

#pragma mark - VDeepLinkSupporter

- (id<VDeeplinkHandler>)deepLinkHandlerForURL:(NSURL *)url
{
    return [[VInboxDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager inboxViewController:self];
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(postedAt)) ascending:NO];

    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

#pragma mark - Message View Controller Cache

- (VConversationContainerViewController *)messageViewControllerFoConversation:(VConversation *)conversation
{
    NSAssert([NSThread isMainThread], @"This method should be called from the main thread only");
    
    if ( self.messageViewControllers == nil )
    {
        self.messageViewControllers = [[NSMutableDictionary alloc] init];
    }
    VConversationContainerViewController *messageViewController = self.messageViewControllers[ conversation.user.remoteId];
    
    if ( messageViewController == nil )
    {
        NSString *title = NSLocalizedString( @"More", @"" );
        NSString *imageName = @"A_more";
        NSDictionary *moreAcessory = @{ VDependencyManagerDestinationKey: [NSNull null],
                                        VDependencyManagerTitleKey: title,
                                        VDependencyManagerIconKey: [UIImage imageNamed:imageName],
                                        VDependencyManagerIdentifierKey: VDependencyManagerAccessoryItemMore,
                                        VDependencyManagerPositionKey: VDependencyManagerPositionRight };
        NSDictionary *childConfiguration = @{ VDependencyManagerAccessoryScreensKey : @[ moreAcessory ] };
        VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
        messageViewController = [VConversationContainerViewController messageViewControllerForConversation:conversation dependencyManager:childDependencyManager];
        self.messageViewControllers[ conversation.user.remoteId ] = messageViewController;
    }
    
    return messageViewController;
}

- (void)removeCachedViewControllerForUser:(VUser *)otherUser
{
    if ( self.messageViewControllers == nil || otherUser.remoteId == nil )
    {
        return;
    }
    [self.messageViewControllers removeObjectForKey:otherUser.remoteId];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell isKindOfClass:[VConversationCell class]] )
    {
        VConversationCell *conversationCell = (VConversationCell *)cell;
        conversationCell.delegate = self;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = (VConversation *)self.dataSource.visibleItems[ indexPath.row ];
    return conversation.remoteId.integerValue > 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        VConversation *conversation = (VConversation *)self.dataSource.visibleItems[ indexPath.row ];
        DeleteConversationOperation *operation = [[DeleteConversationOperation alloc] initWithConversationID:conversation.remoteId.integerValue];
        [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
        {
            if ( error != nil )
            {
                [self removeCachedViewControllerForUser:conversation.user];
            }
            else
            {
                [tableView setEditing:NO animated:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = self.dataSource.visibleItems[ indexPath.row ];
    if (conversation.user)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMessage];
        [self displayConversation:conversation animated:YES];
    }
}

#pragma mark - Actions

- (void)displayConversation:(VConversation *)conversation animated:(BOOL)animated
{
    VConversationContainerViewController *detailVC = [self messageViewControllerFoConversation:conversation];
    UINavigationController *rootInnerNavigationController = [self rootNavigationController].innerNavigationController;
    
    if ( self.navigationController == nil )
    {
        self.userWithQueuedConversation = conversation.user;
    }
    else if ( [rootInnerNavigationController.viewControllers containsObject:detailVC] )
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
}

- (void)refresh
{
    [self.dataSource loadConversations:VPageTypeRefresh completion:^(NSError *_Nullable error)
     {
         [self.refreshControl endRefreshing];
         [self updateTableView];
     }];
}

- (IBAction)refresh:(UIRefreshControl *)refreshControl
{
    [self refresh];
}

- (void)updateTableView
{
    self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    
    switch ( self.dataSource.state )
    {
        case DataSourceStateError:
        case DataSourceStateNoResults: {
            if ( self.tableView.backgroundView != self.noContentView )
            {
                self.tableView.backgroundView = self.noContentView;
                [self.noContentView resetInitialAnimationState];
                [self.noContentView animateTransitionIn];
            }
            break;
        }
            
        default:
            [UIView animateWithDuration:0.5f animations:^void
             {
                 self.tableView.backgroundView = nil;
             }];
            break;
    }
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
    [self.dataSource loadConversations:VPageTypeNext completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
}

#pragma mark - NSNotification handlers

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
}

- (void)loggedInChanged:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
    else
    {
        self.badgeNumber = 0;
    }
}

- (void)inboxMessageNotification:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.dependencyManager.objectManager loadConversationListWithPageType:VPageTypeRefresh
                                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             [self.messageCountCoordinator updateUnreadMessageCount];
             [self updateBadges];
         } failBlock:nil];
        
        [self.dependencyManager.objectManager loadNotificationsListWithPageType:VPageTypeRefresh
                                                                   successBlock:^(NSOperation *__nullable operation, id  __nullable result, NSArray *__nonnull resultObjects)
         {
             [self updateBadges];
         }
                                                                      failBlock:nil];
    }
}

- (void)updateBadges
{
    self.badgeNumber = self.messageCountCoordinator.unreadMessageCount;

    id<VBadgeResponder> badgeResponder = [[self nextResponder] targetForAction:@selector(updateBadge) withSender:nil];
    if (badgeResponder != nil)
    {
        [badgeResponder updateBadge];
    }
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

- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController
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
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:conversation.user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

@end
