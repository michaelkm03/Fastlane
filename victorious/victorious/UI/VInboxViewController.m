//
//  VInboxViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VInboxViewController.h"
#import "UIViewController+VSideMenuViewController.h"
#import "VConversation+RestKit.h"
#import "VMessageContainerViewController.h"
#import "VNewsViewController.h"
#import "VConversationCell.h"
#import "VObjectManager+DirectMessaging.h"


NS_ENUM(NSUInteger, VModeSelect)
{
    kMessageModeSelect,
    kNewsModeSelect
};

static  NSString*   kMessageCellViewIdentifier    =   @"VConversationCell";
static  NSString*   kNewsCellViewIdentifier       =   @"VNewsCell";

@interface VInboxViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl*    modeSelectControl;
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

    self.modeSelectControl.selectedSegmentIndex = kMessageModeSelect;
    [self modeSelected:self.modeSelectControl];

//  [self.modeSelectControl setDividerImage:image1 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//  [self.modeSelectControl setDividerImage:image2 forLeftSegmentState:UIControlStateSelected                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//  [self.modeSelectControl setDividerImage:image3 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateSelected barMetrics:barMetrics];
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

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"lastMessage.postedAt" ascending:YES];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*    theCell;

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VConversation*  info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VConversationCell *)theCell setConversation:info];
    }
    else
    {
//        cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellViewIdentifier forIndexPath:indexPath];
        theCell = [tableView dequeueReusableCellWithIdentifier:kMessageCellViewIdentifier forIndexPath:indexPath];
        VConversation*  info    =   [self.fetchedResultsController objectAtIndexPath:indexPath];
        [(VConversationCell *)theCell setConversation:info];
    }

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
        VConversation* conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [conversation.managedObjectContext deleteObject:conversation];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toMessage" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Actions

- (IBAction)modeSelected:(id)sender
{
    if (0 == [sender selectedSegmentIndex])
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    else
        self.navigationItem.rightBarButtonItem = nil;
    
    self.fetchedResultsController = nil;
    [self performFetch];
}

- (IBAction)showMenu
{
    [self.sideMenuViewController presentMenuViewController];
}

- (IBAction)refreshAction:(id)sender
{
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error.localizedDescription);
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self.tableView reloadData];
    };
    
    //TODO: remove this when we have conversation pagination
    if ([self.fetchedResultsController.fetchedObjects count])
        success(nil, nil, nil);
    
    [[VObjectManager sharedManager] loadNextPageOfConversations:success failBlock: fail];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
