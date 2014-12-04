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
#import "VUserSearchViewController.h"
#import "VLoginViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConversation+RestKit.h"
#import "VNotification+RestKit.h"
#import "VMessageViewController.h"
#import "VMessageContainerViewController.h"
#import "VConversationCell.h"
#import "VNotificationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"
#import "VThemeManager.h"
#import "VNoContentView.h"
#import "VUser.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"

NS_ENUM(NSUInteger, VModeSelect)
{
    kMessageModeSelect      = 0,
    kNotificationModeSelect = 1
};

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";
static NSString * const kNewsCellViewIdentifier    = @"VNewsCell";

@interface VInboxViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSelectControl;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSMutableDictionary *messageViewControllers;

@end

@implementation VInboxViewController

+ (instancetype)inboxViewController
{
    return [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"inbox"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    
    self.modeSelectControl.selectedSegmentIndex = kMessageModeSelect;
    [self modeSelected:self.modeSelectControl];
    
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
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
}

#pragma mark - Segmented Control

- (void)toggleFilterControl:(NSInteger)idx
{
    VModeSelect = idx;
    NSLog(@"\n\n-----\nSelected Index = %lu\n-----\n\n", (unsigned long)VModeSelect);
    
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewControllerWithObjectManager:[VObjectManager sharedManager]] animated:YES completion:NULL];
    }
    
    self.fetchedResultsController = nil;
    [self performFetch];
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = nil;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] init];
    
    if (VModeSelect == kMessageModeSelect)
    {
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];
        sort = [NSSortDescriptor sortDescriptorWithKey:@"postedAt" ascending:NO];
    }
    else if (VModeSelect == kNotificationModeSelect)
    {
        
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VNotification entityName]];
        sort = [NSSortDescriptor sortDescriptorWithKey:@"postedAt" ascending:NO];
    }

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
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:nil] forCellReuseIdentifier:kMessageCellViewIdentifier];
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
        messageViewController = [VMessageContainerViewController messageViewControllerForUser:otherUser];
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

#pragma mark - UITabvleViewDataSource

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
        noMessageView.messageLabel.text = NSLocalizedString(@"NoMessagesMessage", @"");
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

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VConversation  *info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VConversationCell *)theCell setConversation:info];
        ((VConversationCell *)theCell).parentTableViewController = self;
    }
    else
    {
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VNotification *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VNotificationCell *)theCell setNotifcation:info];
        ((VNotificationCell *)theCell).parentTableViewController = self;
    }

    return theCell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kVConversationCellHeight;
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
            VLog(@"Failed to delete conversation: %@", error)
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (conversation.user)
    {
        VMessageContainerViewController *detailVC = [self messageViewControllerForUser:conversation.user];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - Actions

- (IBAction)modeSelected:(id)sender
{
    self.fetchedResultsController = nil;
    [self performFetch];
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        [self.tableView reloadData];
        NSLog(@"%@", error.localizedDescription);
        [self.refreshControl endRefreshing];
        [self setHasMessages:0];
    };
    
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self setHasMessages:self.fetchedResultsController.fetchedObjects.count];
    };

    if (VModeSelect == kMessageModeSelect)
    {
        [[VObjectManager sharedManager] updateUnreadMessageCountWithSuccessBlock:nil failBlock:nil];
        [[VObjectManager sharedManager] refreshConversationListWithSuccessBlock:success failBlock:fail];
    }
    else if (VModeSelect == kNotificationModeSelect)
    {
        [[VObjectManager sharedManager] refreshListOfNotificationsWithSuccessBlock:success failBlock:fail];
    }
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadNextPageOfConversationListWithSuccessBlock:nil failBlock:nil];
}

#pragma mark - Content Creation

- (IBAction)userSearchAction:(id)sender
{
    VUserSearchViewController *userSearch = [VUserSearchViewController sharedInstance];
    [self.navigationController pushViewController:userSearch animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    VAbstractFilter *filter = [[VObjectManager sharedManager] inboxFilterForCurrentUserFromManagedObjectContext:[[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
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

@end
