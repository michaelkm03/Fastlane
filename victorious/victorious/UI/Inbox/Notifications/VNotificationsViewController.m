//
//  VNotificationsViewController.m
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "VNotificationsViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VNoContentView.h"
#import "VNotification+RestKit.h"
#import "VNotificationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager+Login.h"
#import "VPaginationManager.h"
#import "VRootViewController.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VDependencyManager+VObjectManager.h"
#import "VAuthorizationContext.h"
#import "VNavigationDestination.h"

#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+VObjectManager.h"
#import "VAppDelegate.h"
#import "VRootViewController.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VBadgeResponder.h"

static NSString * const kNotificationCellViewIdentifier = @"VNotificationCell";
static CGFloat const kVNotificationCellHeight = 64.0f;
static int const kNotificationFetchBatchSize = 50;
NSString * const VNotificationViewControllerPushReceivedNotification = @"VInboxContainerViewControllerInboxPushReceivedNotification";

@interface VNotificationsViewController () <VNavigationDestination>

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;
@property (strong, nonatomic) RKManagedObjectRequestOperation *refreshRequest;

@end


@implementation VNotificationsViewController

@synthesize multipleContainerChildDelegate = _multipleContainerChildDelegate;
@synthesize badgeNumberUpdateBlock = _badgeNumberUpdateBlock;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VNotificationsViewController *viewController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"VNotificationsViewController"];
    if (viewController)
    {
        viewController.dependencyManager = dependencyManager;
        [dependencyManager configureNavigationItem:viewController.navigationItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(applicationDidBecomeActive:) name:VApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(inboxMessageNotification:) name:VNotificationViewControllerPushReceivedNotification object:nil];

        [viewController loggedInChanged:nil];
    }
    return viewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VAuthorizationContextProvider

- (BOOL)requiresAuthorization
{
    return YES;
}

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextNotification;
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
    self.tableView.contentInset = self.v_layoutInsets;
    self.tableView.contentOffset = CGPointMake(0, -self.v_layoutInsets.top);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kVNotificationCellHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointZero];
    [self markAllNotificationsRead];
    [self refreshTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Notifications"];
    self.badgeNumber = 0;
    
    [self updateNavigationItem];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Notifications"];
    if (self.refreshRequest.isExecuting)
    {
        self.refreshRequest = nil;
    }
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = nil;
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VNotification entityName]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdAt)) ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:kNotificationFetchBatchSize];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kNotificationCellViewIdentifier bundle:nil] forCellReuseIdentifier:kNotificationCellViewIdentifier];
}

#pragma mark - UITableViewDataSource

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self setHasNotifications:self.fetchedResultsController.fetchedObjects.count != 0];
    
    [super controllerDidChangeContent:controller];
}

- (void)setHasNotifications:(BOOL)hasNotifications
{
    if (!hasNotifications)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        VNoContentView *noNotificationsView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        if ( [noNotificationsView respondsToSelector:@selector(setDependencyManager:)] )
        {
            noNotificationsView.dependencyManager = self.dependencyManager;
        }
        noNotificationsView.title = NSLocalizedString(@"NoNotificationsTitle", @"");
        noNotificationsView.message = NSLocalizedString(@"NoNotificationsMessage", @"");
        noNotificationsView.icon = [UIImage imageNamed:@"noNotificationsIcon"];
        self.tableView.backgroundView = noNotificationsView;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VNotificationCell *theCell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellViewIdentifier forIndexPath:indexPath];
    
    VNotification *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [theCell setNotification:info];
    theCell.parentTableViewController = self;
    theCell.dependencyManager = self.dependencyManager;
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VNotification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([notification.deepLink length] > 0)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectNotification];
        [[VRootViewController rootViewController] openURL:[NSURL URLWithString:notification.deepLink]];
    }
}

- (void)markAllNotificationsRead
{
    [[VObjectManager sharedManager] markAllNotificationsRead:nil failBlock:nil];
}

- (void)refreshTableView
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
        VLog(@"Failed to refresh notification list: %@", [error localizedDescription]);
    };
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self.refreshControl endRefreshing];
        
        //Clear all notifications from table except for those returned from the first page call
        NSManagedObjectContext *managedObjectContext = self.fetchedResultsController.managedObjectContext;
        for (NSManagedObject *managedObject in self.fetchedResultsController.fetchedObjects)
        {
            if ( ![resultObjects containsObject:managedObject] )
            {
                [managedObjectContext deleteObject:managedObject];
            }
        }
        [managedObjectContext save:NULL];
        
        if (self.refreshRequest == nil)
        {
            return;
        }
        self.refreshRequest = nil;
        [self setHasNotifications:(self.fetchedResultsController.fetchedObjects.count > 0)];
        [self markAllNotificationsRead];
        [self fetchNotificationCount];

    };
    
    self.refreshRequest = [[VObjectManager sharedManager] loadNotificationsListWithPageType:VPageTypeFirst
                                                                               successBlock:success
                                                                                  failBlock:fail];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [self refreshTableView];
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadNotificationsListWithPageType:VPageTypeNext
                                                         successBlock:nil
                                                            failBlock:nil];
}

#pragma mark - NSNotification handlers

- (void)inboxMessageNotification:(NSNotification *)notification
{
    [self fetchNotificationCount];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if ( badgeNumber == _badgeNumber )
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    id<VBadgeResponder> badgeResponder = [[self nextResponder] targetForAction:@selector(updateBadge:)
                                                                    withSender:nil];
    if ([badgeResponder respondsToSelector:@selector(updateBadge:)])
    {
        [badgeResponder updateBadge:self];
    }

    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock(self.badgeNumber);
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self fetchNotificationCount];
    }
}

- (void)fetchNotificationCount
{
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
    };
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if ([fullResponse isKindOfClass:[NSDictionary class]])
        {
            NSNumber *unread = [(NSDictionary *)fullResponse[@"payload"] objectForKey: @"unread_count"];
            self.badgeNumber = [unread integerValue];
        }
    };
    [[VObjectManager sharedManager] notificationsCount:success failBlock:fail];
}

- (void)loggedInChanged:(NSNotification *)notification
{
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self fetchNotificationCount];
    }
    else
    {
        self.badgeNumber = 0;
    }
}

- (void)updateNavigationItem
{
    UINavigationItem *navigationItem = self.navigationItem;
    if ( self.multipleContainerChildDelegate != nil )
    {
        navigationItem = [self.multipleContainerChildDelegate parentNavigationItem];
    }
    [self.dependencyManager addAccessoryScreensToNavigationItem:navigationItem fromViewController:self];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    VAbstractFilter *filter = [[VObjectManager sharedManager] notificationFilterForCurrentUserFromManagedObjectContext:context];
    
    if ( [self scrollView:scrollView shouldLoadNextPageOfFilter:filter] )
    {
        [self loadNextPageAction];
    }
}

#pragma mark - Navigation Destination

- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem
{
    return YES;
}

- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source
{
    if ([menuItem.identifier isEqualToString:VDependencyManagerAccessoryNewMessage])
    {
        return NO;
    }
    return YES;
}

@end
