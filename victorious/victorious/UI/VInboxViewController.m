//
//  VInboxViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VInboxViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConversation+RestKit.h"
#import "VMessageContainerViewController.h"
#import "VNewsViewController.h"
#import "VConversationCell.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VThemeManager.h"

#import "VNoContentView.h"


NS_ENUM(NSUInteger, VModeSelect)
{
    kMessageModeSelect,
    kNewsModeSelect
};

static  NSString*   kMessageCellViewIdentifier    =   @"VConversationCell";
static  NSString*   kNewsCellViewIdentifier       =   @"VNewsCell";

@interface VInboxViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl*    modeSelectControl;
@property (weak, nonatomic) IBOutlet UIView*                headerView;
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
    
//    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
//    self.tableView.separatorColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.navigationController.navigationBar.barTintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
    self.headerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setHasMessages:self.fetchedResultsController.fetchedObjects.count];
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

#pragma mark - Overrides

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = nil;
    
    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];
    else if (kNewsModeSelect == self.modeSelectControl.selectedSegmentIndex)
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VConversation entityName]];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastMessage.postedAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:context
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:nil] forCellReuseIdentifier:kMessageCellViewIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:nil] forCellReuseIdentifier:kMessageCellViewIdentifier];

//  [self.tableView registerNib:[UINib nibWithNibName:kNewsCellViewIdentifier bundle:nil] forCellReuseIdentifier:kNewsCellViewIdentifier];
//  [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kNewsCellViewIdentifier bundle:nil] forCellReuseIdentifier:kNewsCellViewIdentifier];
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
        VNoContentView* noMessagesView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = noMessagesView;
        noMessagesView.titleLabel.text = NSLocalizedString(@"NoMessagesTitle", @"");
        noMessagesView.messageLabel.text = NSLocalizedString(@"NoMessagesMessage", @"");
        noMessagesView.iconImageView.image = [UIImage imageNamed:@"noMessageIcon"];
        
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
//        cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellViewIdentifier forIndexPath:indexPath];
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VConversation*  info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VConversationCell *)theCell setConversation:info];
        ((VConversationCell*)theCell).parentTableViewController = self;
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
    [self performSegueWithIdentifier:@"toMessage" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
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
        NSLog(@"%@", error.localizedDescription);
        [self.refreshControl endRefreshing];
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    };

    [[VObjectManager sharedManager] refreshConversationListWithSuccessBlock:success failBlock:fail];
}

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadNextPageOfConversationListWithSuccessBlock:nil failBlock:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"BackButton", @"")
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];

    if ([segue.identifier isEqualToString:@"toMessage"])
    {
        VMessageContainerViewController *subview = (VMessageContainerViewController *)segue.destinationViewController;
        UITableViewCell* cell = (UITableViewCell*)sender;

        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        subview.conversation = conversation;
    }
    else if ([segue.identifier isEqualToString:@"toNews"])
    {
//        VNewsViewController *subview = (VNewsViewController *)segue.destinationViewController;
//        UITableViewCell* cell = (UITableViewCell*)sender;
//        
//        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        
//        [subview setConversation:conversation];
    }
}

@end
