//
//  VInboxViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VInboxViewController.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VUserSearchViewController.h"
#import "VLoginViewController.h"
#import "VConversation+RestKit.h"
#import "VNotification+RestKit.h"
#import "VMessageViewController.h"
#import "VMessageContainerViewController.h"
#import "VConversationCell.h"
#import "VNotificationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VPaginationManager.h"
#import "VRootViewController.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUser.h"
#import "VObjectManager+Login.h"
#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+VObjectManager.h"
#import "NSURL+VPathHelper.h"
#import "VInboxDeeplinkHandler.h"
#import "VNavigationController.h"
#import "VAuthorizedAction.h"
#import "VNavigationController.h"

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";
static const CGFloat kConversationCellHeight = 72;

@interface VInboxViewController () <VUserSearchViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *messageViewControllers;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic) NSInteger badgeNumber;
@property (copy, nonatomic) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;
@property (strong, nonatomic) RKManagedObjectRequestOperation *refreshRequest;

@end

static char kKVOContext;

NSString * const VInboxViewControllerDeeplinkHostComponent = @"inbox";
NSString * const VInboxViewControllerInboxPushReceivedNotification = @"VInboxContainerViewControllerInboxPushReceivedNotification";

@implementation VInboxViewController

@synthesize multipleContainerChildDelegate;

+ (instancetype)inboxViewController
{
    return [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"inbox"];
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VInboxViewController *viewController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"inbox"];
    if (viewController)
    {
        viewController.dependencyManager = dependencyManager;
        viewController.messageCountCoordinator = [[VUnreadMessageCountCoordinator alloc] initWithObjectManager:[dependencyManager objectManager]];
        viewController.title = NSLocalizedString(@"Messages", @"");
        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profileCompose"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:viewController
                                                                                 action:@selector(userSearchAction:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(inboxMessageNotification:) name:VInboxViewControllerInboxPushReceivedNotification object:nil];
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
    
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kConversationCellHeight;
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [self.refreshControl beginRefreshing];
    [self refresh:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Inbox"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Inbox"];
    if (self.refreshRequest.isExecuting)
    {
        self.refreshRequest = nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Properties

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
    if ( badgeNumber == _badgeNumber )
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock(self.badgeNumber);
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

#pragma mark -

- (id<VDeeplinkHandler>)deepLinkHandler
{
    return [[VInboxDeepLinkHandler alloc] initWithDependencyManager:self.dependencyManager inboxViewController:self];
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"postedAt" ascending:NO];

    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:nil] forCellReuseIdentifier:kMessageCellViewIdentifier];
}

#pragma mark - Message View Controller Cache

- (VMessageContainerViewController *)messageViewControllerForUser:(VUser *)otherUser
{
    NSAssert([NSThread isMainThread], @"This method should be called from the main thread only");
    
    if ( self.messageViewControllers == nil )
    {
        self.messageViewControllers = [[NSMutableDictionary alloc] init];
    }
    VMessageContainerViewController *messageViewController = self.messageViewControllers[otherUser.remoteId];
    
    if ( messageViewController == nil )
    {
        messageViewController = [VMessageContainerViewController messageViewControllerForUser:otherUser dependencyManager:self.dependencyManager];
        self.messageViewControllers[otherUser.remoteId] = messageViewController;
    }
    [(VMessageViewController *)messageViewController.conversationTableViewController setShouldRefreshOnAppearance:YES];
    
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

#pragma mark - UITableViewDataSource

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self setHasMessages:self.fetchedResultsController.fetchedObjects.count];

    [super controllerDidChangeContent:controller];
}

- (void)setHasMessages:(BOOL)hasMessages
{
    if (!hasMessages)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        VNoContentView *noMessageView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        noMessageView.titleLabel.text = NSLocalizedString(@"NoMessagesTitle", @"");
        noMessageView.titleLabel.textColor = [UIColor whiteColor];
        noMessageView.messageLabel.text = NSLocalizedString(@"NoMessagesMessage", @"");
        noMessageView.messageLabel.textColor = [UIColor whiteColor];
        noMessageView.iconImageView.image = [UIImage imageNamed:@"noMessageIcon"];
        self.tableView.backgroundView = noMessageView;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
    VConversationCell *theCell = (VConversationCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
    [theCell setConversation:info];
    theCell.parentTableViewController = self;
    theCell.dependencyManager = self.dependencyManager;
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        VConversation *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[VObjectManager sharedManager] deleteConversation:conversation
                                              successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self removeCachedViewControllerForUser:conversation.user];
            NSManagedObjectContext *context =   conversation.managedObjectContext;
            [context deleteObject:conversation];
            [context saveToPersistentStore:nil];
        }
                                                 failBlock:^(NSOperation *operation, NSError *error)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"ConversationDelError", @"");
            [hud hide:YES afterDelay:3.0];
            [tableView setEditing:NO animated:YES];
            VLog(@"Failed to delete conversation: %@", [error localizedDescription]);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (conversation.user)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectMessage];
        
        [self displayConversationForUser:conversation.user animated:YES];
    }
}

#pragma mark - Actions

- (void)displayConversationForUser:(VUser *)user animated:(BOOL)animated
{
    VMessageContainerViewController *detailVC = [self messageViewControllerForUser:user];
    
    if ( [self.navigationController.viewControllers containsObject:detailVC] )
    {
        if ( self.navigationController.topViewController != detailVC )
        {
            [self.navigationController popToViewController:detailVC animated:animated];
        }
    }
    else
    {
        detailVC.messageCountCoordinator = self.messageCountCoordinator;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    if (self.refreshRequest != nil)
    {
        return;
    }
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        [self.refreshControl endRefreshing];
        if (self.refreshRequest == nil)
        {
            return;
        }
        self.refreshRequest = nil;
        UIView *viewForHUD = self.parentViewController.view;
        
        if (viewForHUD == nil )
        {
            viewForHUD = self.view;
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewForHUD animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"RefreshError", @"");
        [hud hide:YES afterDelay:3.0];
        VLog(@"Failed to refresh conversation list: %@", [error localizedDescription]);
    };
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (self.refreshRequest == nil)
        {
            [self.refreshControl endRefreshing];
            return;
        }
        self.refreshRequest = nil;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [self setHasMessages:(self.fetchedResultsController.fetchedObjects.count > 0)];
        [self.messageCountCoordinator updateUnreadMessageCount];
    };

    self.refreshRequest = [[VObjectManager sharedManager] loadConversationListWithPageType:VPageTypeFirst
                                                                              successBlock:success failBlock:fail];
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadConversationListWithPageType:VPageTypeNext
                                                        successBlock:nil failBlock:nil];
}

#pragma mark - Search

- (IBAction)userSearchAction:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreateMessage];
    
    VUserSearchViewController *userSearch = [VUserSearchViewController newWithDependencyManager:self.dependencyManager];
    userSearch.searchContext = VObjectManagerSearchContextMessage;
    userSearch.messageSearchDelegate = self;
    
    //Create a navigation controller that will hold the user search view controller
    VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
    navigationController.innerNavigationController.viewControllers = @[userSearch];
    navigationController.innerNavigationController.navigationBarHidden = YES;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didSelectUser:(VUser *)user inUserSearchViewController:(VUserSearchViewController *)userSearchViewController
{
    [self displayConversationForUser:user animated:NO];
    
    /*
     Call this to update the top bar before dismissing since UINavigationDelegate methods will not fire
     from a navigation controller that is not in the foreground and thus not update the top bar appearance
     */
    [[self v_navigationController] updateSupplementaryHeaderViewForViewController:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    VAbstractFilter *filter = [[VObjectManager sharedManager] inboxFilterForCurrentUserFromManagedObjectContext:context];
                               CGFloat scrollThreshold = scrollView.contentSize.height * 0.75f;
    
    if (filter.currentPageNumber.intValue < filter.maxPageNumber.intValue &&
        [[self.fetchedResultsController sections][0] numberOfObjects] &&
        ![[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollThreshold)
    {
        [self loadNextPageAction];
    }
    
    //Notify the container about the scroll so it can handle the header
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
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
        [self.dependencyManager.objectManager loadConversationListWithPageType:VPageTypeFirst
                                                                  successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
         {
             [self.messageCountCoordinator updateUnreadMessageCount];
         } failBlock:nil];
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

@end
