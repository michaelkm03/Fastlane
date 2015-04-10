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
#import "VDependencyManager+VObjectManager.h"
#import "VAuthorizationContext.h"
#import "VNavigationDestination.h"

#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+VObjectManager.h"
#import "VAppDelegate.h"
#import "VRootViewController.h"

static NSString * const kNotificationCellViewIdentifier = @"VNotificationCell";
static CGFloat const kVNotificationCellHeight = 56;
static int const kNotificationFetchBatchSize = 50;

@interface VNotificationsViewController () <VNavigationDestination>

@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (nonatomic) NSInteger badgeNumber;
@property (copy, nonatomic) VNavigationMenuItemBadgeNumberUpdateBlock badgeNumberUpdateBlock;

@end


@implementation VNotificationsViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VNotificationsViewController *viewController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"VNotificationsViewController"];
    if (viewController)
    {
        viewController.dependencyManager = dependencyManager;
        viewController.title = @"Notifications";
        viewController.navigationItem.rightBarButtonItem = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:viewController selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [viewController loggedInChanged:nil];
    }
    return viewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VNavigationDestination

- (VAuthorizationContext)authorizationContext
{
    return VAuthorizationContextNotification;
}

#pragma mark -  Container Child

- (void)viewControllerSelected:(BOOL)isDefault
{
    
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = self.v_layoutInsets;
    self.tableView.contentOffset = CGPointMake(0, -self.v_layoutInsets.top);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kVNotificationCellHeight;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.refreshControl beginRefreshing];
    [self refresh:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:@"Notifications"];
    self.badgeNumber = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Notifications"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
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
    [self setHasNotifications:self.fetchedResultsController.fetchedObjects.count];
    
    [super controllerDidChangeContent:controller];
}

- (void)setHasNotifications:(BOOL)hasMessages
{
    if (!hasMessages)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        VNoContentView *noMessageView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
        noMessageView.titleLabel.text = NSLocalizedString(@"NoNotificationsTitle", @"");
        noMessageView.titleLabel.textColor = [UIColor whiteColor];
        noMessageView.messageLabel.text = NSLocalizedString(@"NoNotificationsMessage", @"");
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
    VNotificationCell *theCell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellViewIdentifier forIndexPath:indexPath];
    
    VNotification *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [theCell setNotification:info];
    theCell.parentTableViewController = self;
    
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
    if ([notification.deeplink length] > 0)
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectNotification];
        
        [[VRootViewController rootViewController] handleDeeplinkURL:[NSURL URLWithString:notification.deeplink]];
        
    }
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        [self.refreshControl endRefreshing];
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
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self setHasNotifications:(self.fetchedResultsController.fetchedObjects.count > 0)];
        VFailBlock fail = ^(NSOperation *operation, NSError *error)
        {
        };
        VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
        {
            [self.tableView reloadData];
        };
        [[VObjectManager sharedManager] markAllNotificationsRead:success failBlock:fail];
    };
    
    [[VObjectManager sharedManager] loadNotificationsListWithPageType:VPageTypeFirst
                                                        successBlock:success failBlock:fail];
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadNotificationsListWithPageType:VPageTypeNext
                                                        successBlock:nil failBlock:nil];
}

#pragma mark - NSNotification handlers

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

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self refresh:nil];
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
    // Placeholder for dealing with badges.
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self fetchNotificationCount];
    }
    else
    {
        self.badgeNumber = 0;
    }
}

@end
