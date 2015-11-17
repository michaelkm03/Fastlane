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
#import "VConversation+RestKit.h"
#import "VMessageViewController.h"
#import "VMessageContainerViewController.h"
#import "VConversationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Users.h"
#import "VRootViewController.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUser.h"
#import "VObjectManager+Login.h"
#import "VDependencyManager+VObjectManager.h"
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

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";

@interface VInboxViewController () <VUserSearchViewControllerDelegate, VProvidesNavigationMenuItemBadge>

@property (strong, nonatomic) NSMutableDictionary *messageViewControllers;
@property (strong, nonatomic) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (strong, nonatomic) RKManagedObjectRequestOperation *refreshRequest;
@property (nonatomic, strong) VUser *userWithQueuedConversation;

@end

static char kKVOContext;

NSString * const VInboxViewControllerDeeplinkHostComponent = @"inbox";
NSString * const VInboxViewControllerInboxPushReceivedNotification = @"VInboxContainerViewControllerInboxPushReceivedNotification";

@implementation VInboxViewController

@synthesize multipleContainerChildDelegate = _multipleContainerChildDelegate;
@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

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
        [dependencyManager configureNavigationItem:viewController.navigationItem];
        
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
    // Empty
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = VConversationCellHeight;
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    [self refresh:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateNavigationItem];
    
    [self.dependencyManager trackViewWillAppear:self];
    
    [self.refreshControl beginRefreshing];

    [self refresh:nil];
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
        [self displayConversationForUser:self.userWithQueuedConversation animated:YES];
        self.userWithQueuedConversation = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
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
        NSString *title = NSLocalizedString( @"More", @"" );
        NSString *imageName = @"A_more";
        NSDictionary *moreAcessory = @{ VDependencyManagerDestinationKey: [NSNull null],
                                        VDependencyManagerTitleKey: title,
                                        VDependencyManagerIconKey: [UIImage imageNamed:imageName],
                                        VDependencyManagerIdentifierKey: VDependencyManagerAccessoryItemMore,
                                        VDependencyManagerPositionKey: VDependencyManagerPositionRight };
        NSDictionary *childConfiguration = @{ VDependencyManagerAccessoryScreensKey : @[ moreAcessory ] };
        VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
        messageViewController = [VMessageContainerViewController messageViewControllerForUser:otherUser dependencyManager:childDependencyManager];
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
        if ( [noMessageView respondsToSelector:@selector(setDependencyManager:)] )
        {
            noMessageView.dependencyManager = self.dependencyManager;
        }
        noMessageView.title = NSLocalizedString(@"NoMessagesTitle", @"");
        noMessageView.message = NSLocalizedString(@"NoMessagesMessage", @"");
        noMessageView.icon = [UIImage imageNamed:@"noMessagesIcon"];
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
    UINavigationController *rootInnerNavigationController = [self rootNavigationController].innerNavigationController;
    
    if ( self.navigationController == nil )
    {
        self.userWithQueuedConversation = user;
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
        // TODO: Show error in non-disruptive way
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
        [self updateBadges];
    };

    self.refreshRequest = [[VObjectManager sharedManager] loadConversationListWithPageType:VPageTypeFirst
                                                                              successBlock:success
                                                                                 failBlock:fail];
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadConversationListWithPageType:VPageTypeNext
                                                        successBlock:nil
                                                           failBlock:nil];
}

#pragma mark - VAccessoryNavigationSource

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    if ( [menuItem.destination isKindOfClass:[VMessageContainerViewController class]] )
    {
        [self showUserSearch];
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    return YES;
}

#pragma mark - Search

- (void)showUserSearch
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectCreateMessage];
    
    VUserSearchViewController *userSearch = [VUserSearchViewController newWithDependencyManager:self.dependencyManager];
    userSearch.searchContext = VObjectManagerSearchContextMessage;
    userSearch.messageSearchDelegate = self;
    userSearch.userSearchPresenter = VUserSearchPresenterMessages;
    
    //Create a navigation controller that will hold the user search view controller
    VNavigationController *navigationController = [[VNavigationController alloc] initWithDependencyManager:self.dependencyManager];
    navigationController.innerNavigationController.viewControllers = @[userSearch];
    navigationController.innerNavigationController.navigationBarHidden = YES;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didSelectUser:(VUser *)user inUserSearchViewController:(VUserSearchViewController *)userSearchViewController
{
    if ( user != nil )
    {
        [self displayConversationForUser:user animated:NO];
    }
    
    /*
     Call this to update the top bar before dismissing since UINavigationDelegate methods will not fire
     from a navigation controller that is not in the foreground and thus not update the top bar appearance
     */
    [[self v_navigationController] updateSupplementaryHeaderViewForViewController:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    VAbstractFilter *filter = [[VObjectManager sharedManager] inboxFilterForCurrentUserFromManagedObjectContext:context];
    
    if ( [self scrollView:scrollView shouldLoadNextPageOfFilter:filter] )
    {
        [self loadNextPageAction];
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
             [self updateBadges];
         } failBlock:nil];
        
        [self.dependencyManager.objectManager loadNotificationsListWithPageType:VPageTypeFirst
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

@end
