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


#import "UIViewController+VLayoutInsets.h"
#import "VDependencyManager+VObjectManager.h"
#import "VAppDelegate.h"
#import "VRootViewController.h"

static NSString * const kNotificationCellViewIdentifier = @"VNotificationCell";

@interface VNotificationsViewController ()

@property (strong, nonatomic) VDependencyManager *dependencyManager;

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
    }
    return viewController;
}

/*
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"VNotificationsViewController"];
    if (self)
    {
        _dependencyManager = dependencyManager;
        self.title = @"Notifications";
        self.navigationItem.rightBarButtonItem = nil;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInChanged:) name:kLoggedInChangedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxMessageNotification:) name:VInboxViewControllerInboxPushReceivedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
 */

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.contentInset = self.v_layoutInsets;
    self.tableView.contentOffset = CGPointMake(0, -self.v_layoutInsets.top);
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
    [[VTrackingManager sharedInstance] startEvent:@"Inbox"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:@"Inbox"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = nil;
//    NSSortDescriptor *sort = [[NSSortDescriptor alloc] init];
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VNotification entityName]];
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
        noMessageView.messageLabel.text = NSLocalizedString(@"NoNotificationsMessage", @"");
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
    UITableViewCell    *theCell;
    
    theCell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellViewIdentifier forIndexPath:indexPath];
    
    VNotification  *info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(VNotificationCell *)theCell setNotification:info];
    ((VNotificationCell *)theCell).parentTableViewController = self;
    
    return theCell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kVNotificationCellHeight;
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
//        [self.messageCountCoordinator updateUnreadMessageCount];
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

- (void)loggedInChanged:(NSNotification *)notification
{
    /*
    if ( self.dependencyManager.objectManager.mainUserLoggedIn )
    {
        [self.messageCountCoordinator updateUnreadMessageCount];
    }
    else
    {
        self.badgeNumber = 0;
    }
     */
}

@end
