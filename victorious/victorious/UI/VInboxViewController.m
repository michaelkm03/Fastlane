//
//  VInboxViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VConstants.h"
#import "VInboxViewController.h"
#import "VUserSearchViewController.h"
#import "VLoginViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConversation+RestKit.h"
#import "VNotification+RestKit.h"
#import "VMessageViewController.h"
#import "VMessageContainerViewController.h"
#import "VNewsViewController.h"
#import "VConversationCell.h"
#import "VNotificationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"
#import "VThemeManager.h"
#import "VNoContentView.h"


NS_ENUM(NSUInteger, VModeSelect)
{
    kMessageModeSelect      = 0,
    kNotificationModeSelect = 1
};

static NSString * const kMessageCellViewIdentifier = @"VConversationCell";
static NSString * const kNewsCellViewIdentifier    = @"VNewsCell";

@interface VInboxViewController ()

@property (weak, nonatomic)   IBOutlet UISegmentedControl *modeSelectControl;
@property (weak, nonatomic)   IBOutlet UIView             *headerView;
@property (strong, nonatomic) NSMutableDictionary         *detailViewControllers;

@end

@implementation VInboxViewController

+ (instancetype)inboxViewController
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    return (VInboxViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"inbox"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    
    self.modeSelectControl.selectedSegmentIndex = kMessageModeSelect;
    [self modeSelected:self.modeSelectControl];
    
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    
    self.detailViewControllers = [[NSMutableDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Inbox"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

#pragma mark - Segmented Control
- (void)toggleFilterControl:(NSInteger)idx
{
    VModeSelect = idx;
    NSLog(@"\n\n-----\nSelected Index = %d\n-----\n\n",VModeSelect);
    
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
    }
    
    self.fetchedResultsController = nil;
    [self performFetch];
}

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = nil;
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] init];
    
    if (VModeSelect == kMessageModeSelect)
    {
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];
        sort = [NSSortDescriptor sortDescriptorWithKey:@"lastMessage.postedAt" ascending:NO];
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
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*    theCell;

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VConversation*  info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VConversationCell *)theCell setConversation:info];
        ((VConversationCell*)theCell).parentTableViewController = self;
    }
    else
    {
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VNotification *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VNotificationCell *)theCell setNotifcation:info];
        ((VNotificationCell*)theCell).parentTableViewController = self;
    }

    return theCell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
        return YES;
    else
        return NO;
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
        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[VObjectManager sharedManager] deleteConversation:conversation
                                              successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
        {
            NSManagedObjectContext* context =   conversation.managedObjectContext;
            [context deleteObject:conversation];
            [context saveToPersistentStore:nil];
        }
                                                 failBlock:^(NSOperation* operation, NSError* error)
        {
            VLog(@"Failed to delete conversation: %@", error)
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    VMessageContainerViewController *detailVC = self.detailViewControllers[conversation.remoteId];
    if (!detailVC)
    {
        detailVC = (VMessageContainerViewController *)[self.storyboard instantiateViewControllerWithIdentifier:kMessageContainerID];
        detailVC.otherUser = conversation.user;
        self.detailViewControllers[conversation.remoteId] = detailVC;
    }
    [(VMessageViewController *)detailVC.conversationTableViewController setShouldRefreshOnAppearance:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
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
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        [self.tableView reloadData];
        NSLog(@"%@", error.localizedDescription);
        [self.refreshControl endRefreshing];
        [self setHasMessages:0];
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        [self setHasMessages:self.fetchedResultsController.fetchedObjects.count];
    };

    if (VModeSelect == kMessageModeSelect)
    {
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    VAbstractFilter *filter = [[VObjectManager sharedManager] inboxFilterForCurrentUserFromManagedObjectContext:[[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
    if (filter.currentPageNumber.intValue < filter.maxPageNumber.intValue &&
        [[self.fetchedResultsController sections][0] numberOfObjects] &&
        ![[[VObjectManager sharedManager] paginationManager] isLoadingFilter:filter] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
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
