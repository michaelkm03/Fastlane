//
//  VMessagesViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VInboxViewController.h"
#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"
#import "VConversation+RestKit.h"
#import "VMessageSubViewController.h"
#import "VNewsViewController.h"
#import "VConversationCell.h"

NS_ENUM(NSUInteger, ModeSelect)
{
    kMessageModeSelect,
    kNewsModeSelect
};

static  NSString*   kMessageCellViewIdentifier    =   @"VConversationCell";
static  NSString*   kNewsCellViewIdentifier       =   @"VNewsCell";

@interface VInboxViewController ()   <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl*    modeSelectControl;
@end

@implementation VInboxViewController

+ (instancetype)sharedInboxViewController
{
    static  VInboxViewController*   inboxViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        inboxViewController = (VInboxViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"inbox"];
    });
    
    return inboxViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.modeSelectControl.selectedSegmentIndex = 0;
    [self modeSelected:self.modeSelectControl];
    
//        [self.modeSelectControl setDividerImage:image1 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//        [self.modeSelectControl setDividerImage:image2 forLeftSegmentState:UIControlStateSelected                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//        [self.modeSelectControl setDividerImage:image3 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateSelected barMetrics:barMetrics];
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    id      info    =   [self.fetchedResultsController objectAtIndexPath:theIndexPath];
    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
        [(VConversationCell *)theCell setConversation:info];
    else
        ;
}

////- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
////{
////  if message, return X
////  if message and reply, return Y
////  if news, return Z
////}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*    cell;

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
        cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellViewIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

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
        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [conversation.managedObjectContext deleteObject:conversation];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toMessage" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
        [fetchRequest setEntity:[NSEntityDescription entityForName:[VConversation entityName] inManagedObjectContext:context]];
    }
    else if (kNewsModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
//        [fetchRequest setEntity:[NSEntityDescription entityForName:[VNews entityName] inManagedObjectContext:context]];
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastMessage.postedAt" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return fetchRequest;
}

#pragma mark - Cell Lifecycle

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kMessageCellViewIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kMessageCellViewIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kMessageCellViewIdentifier];

//    [self.tableView registerNib:[UINib nibWithNibName:kNewsCellViewIdentifier bundle:[NSBundle mainBundle]]
//         forCellReuseIdentifier:kNewsCellViewIdentifier];
//    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kNewsCellViewIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kNewsCellViewIdentifier];
}

#pragma mark - Refresh Lifecycle

- (void)refreshAction
{
    NSManagedObjectContext* context =  [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^{
        
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        [self.refreshControl endRefreshing];
    }];

}

- (IBAction)modeSelected:(id)sender
{
    if (0 == [sender selectedSegmentIndex])
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    else
        self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toMessage"])
    {
        VMessageSubViewController *subview = (VMessageSubViewController *)segue.destinationViewController;
        UITableViewCell* cell = (UITableViewCell*)sender;

        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];

        [subview setConversation:conversation];
    }
    else if ([segue.identifier isEqualToString:@"toNews"])
    {
        VNewsViewController *subview = (VNewsViewController *)segue.destinationViewController;
        UITableViewCell* cell = (UITableViewCell*)sender;
        
        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        
        [subview setConversation:conversation];
    }
    else if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
