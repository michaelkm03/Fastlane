//
//  VNotificationsViewController.m
//  victorious
//
//  Created by Edward Arenberg on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotificationsViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VNotificationCell.h"
#import "VRootViewController.h"
#import "VDependencyManager+VAccessoryScreens.h"
#import "VDependencyManager+VNavigationItem.h"
#import "VNavigationDestination.h"
#import "UIViewController+VAccessoryScreens.h"
#import "UIViewController+VLayoutInsets.h"
#import "VBadgeResponder.h"
#import "VDependencyManager+VTracking.h"
#import "VConversationListViewController.h"
#import "victorious-Swift.h"

static NSString * const kNotificationCellViewIdentifier = @"VNotificationCell";
static CGFloat const kVNotificationCellHeight = 64.0f;

@interface VNotificationsViewController () <VNavigationDestination, VCellWithProfileDelegate, VScrollPaginatorDelegate, VPaginatedDataSourceDelegate>

@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;

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
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(inboxMessageNotification:) name:VConversationListViewControllerInboxPushReceivedNotification object:nil];

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
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    self.dataSource = [[NotificationsDataSource alloc] initWithDependencyManager:self.dependencyManager];
    [self.dataSource registerCells:self.tableView];
    self.dataSource.delegate = self;
    self.tableView.dataSource = self.dataSource;
    
    self.tableView.contentInset = self.v_layoutInsets;
    self.tableView.contentOffset = CGPointMake(0, -self.v_layoutInsets.top);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kVNotificationCellHeight;
    self.tableView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.noContentView = [VNoContentView viewFromNibWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = NSLocalizedString(@"NoNotificationsTitle", @"");
    self.noContentView.message = NSLocalizedString(@"NoNotificationsMessage", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noNotificationsIcon"];
    
    // Removes the separaters for empty rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
    
    [self.refreshControl beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
    [self updateNavigationItem];
    
    // Reload first page from network (some network latency)
    [self refresh];
    
    [self updateTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Notifications"];
    self.badgeNumber = 0;
    
    [self v_addBadgingToAccessoryScreensWithDependencyManager:self.dependencyManager];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[VTrackingManager sharedInstance] endEvent:@"Notifications"];
}

#pragma mark - Overrides

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kNotificationCellViewIdentifier bundle:nil] forCellReuseIdentifier:kNotificationCellViewIdentifier];
}

- (void)updateTableView
{
    self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    
    switch ( [self.dataSource state] )
    {
        case VDataSourceStateError:
        case VDataSourceStateNoResults: {
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
    VNotification *notification = [self.dataSource.visibleItems objectAtIndex:indexPath.row];
    if ([notification.deepLink length] > 0)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectNotification];
        [[VRootViewController sharedRootViewController] openURL:[NSURL URLWithString:notification.deepLink]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [cell isKindOfClass:[VNotificationCell class]] )
    {
        VNotificationCell *notificationCell = (VNotificationCell *)cell;
        notificationCell.delegate = self;
    }
}

- (void)redecorateVisibleCells
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        if ([cell isKindOfClass:VNotificationCell.class])
        {
            [self.dataSource decorateWithCell:(VNotificationCell *)cell atIndexPath:[self.tableView indexPathForCell:cell]];
        }
    }
}

- (void)markAllItemsAsRead
{
    MarkAllNotificationsAsReadOperation *operation = [[MarkAllNotificationsAsReadOperation alloc] init];
    [operation queueOn:operation.defaultQueue completionBlock:nil];
}

- (void)refresh
{
    [self.dataSource loadNotifications:VPageTypeFirst completion:^(NSError *_Nullable error)
     {
         [self.refreshControl endRefreshing];
         [self updateTableView];
         [self markAllItemsAsRead];
         [self redecorateVisibleCells];
     }];
}

- (IBAction)refresh:(UIRefreshControl *)refreshControl
{
    [self refresh];
}

#pragma mark - NSNotification handlers

- (void)inboxMessageNotification:(NSNotification *)notification
{
    [self fetchNotificationCount];
    
    [self.dataSource refreshRemote:^(NSArray *array, NSError *error)
     {
         // Don't need to redecorate visible cells here, because new notification objects are created based off of createdAt and subject properties
     }];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    if ( badgeNumber == _badgeNumber )
    {
        return;
    }
    _badgeNumber = badgeNumber;
    
    id<VBadgeResponder> badgeResponder = [[self nextResponder] targetForAction:@selector(updateBadge) withSender:nil];
    if (badgeResponder != nil)
    {
        [badgeResponder updateBadge];
    }
    
    if ( self.badgeNumberUpdateBlock != nil )
    {
        self.badgeNumberUpdateBlock(self.badgeNumber);
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ( [VCurrentUser user] != nil )
    {
        [self fetchNotificationCount];
    }
}

- (void)fetchNotificationCount
{
    if ([AgeGate isAnonymousUser])
    {
        return;
    }
    
    UnreadNotificationsCountOperation *operation = [[UnreadNotificationsCountOperation alloc] init];
    [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
    {
        if ( operation.unreadNotificationsCount != nil )
        {
            self.badgeNumber = operation.unreadNotificationsCount.integerValue;
        }
    }];
}

- (void)loggedInChanged:(NSNotification *)notification
{
    [self.dataSource unload];
    
    if ( [VCurrentUser user] != nil )
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
    [self v_addAccessoryScreensWithDependencyManager:self.dependencyManager];
}

#pragma mark - Pagination

- (void)shouldLoadNextPage
{
    [self.dataSource loadNotifications:VPageTypeNext completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
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

#pragma mark - VCellWithProfileDelegate

- (void)cellDidSelectProfile:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if ( indexPath == nil )
    {
        return;
    }
    
    VNotification *notification = [self.dataSource.visibleItems objectAtIndex:indexPath.row];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:notification.user];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - VPaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [self.tableView v_applyChangeInSection:0 from:oldValue to:newValue];
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didChangeStateFrom:(enum VDataSourceState)oldState to:(enum VDataSourceState)newState
{
    [self updateTableView];
}

@end
