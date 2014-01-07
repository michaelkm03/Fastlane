//
//  VMessagesViewController.m
//  victorious
//
//  Created by Gary Philipp on 12/23/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VInboxViewController.h"
#import "VComment+RestKit.h"
#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"

NS_ENUM(NSUInteger, ModeSelect)
{
    kMessageModeSelect,
    kNewsModeSelect
};

static  NSString*   kMessageCell    =   @"messageCell";
static  NSString*   kNewsCell       =   @"newsCell";

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
    [self modeSelected:self];


//        [self.modeSelectControl setDividerImage:image1 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//        [self.modeSelectControl setDividerImage:image2 forLeftSegmentState:UIControlStateSelected                   rightSegmentState:UIControlStateNormal barMetrics:barMetrics];
//        [self.modeSelectControl setDividerImage:image3 forLeftSegmentState:UIControlStateNormal                   rightSegmentState:UIControlStateSelected barMetrics:barMetrics];
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
////    id      info    =   [self.fetchedResultsController objectAtIndexPath:theIndexPath];
//
//    if (kMessageModeSelect == self.modeSelect)
//    {
//        
//    }
//    else
//    {
//        
//    }
//
////    VSequence *info = [self.fetchedResultsController objectAtIndexPath:theIndexPath];
////    [theCell setSequence:info];
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
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kMessageCell forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kNewsCell forIndexPath:indexPath];
    }
    
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
        // Delete the row from the data source
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription*    entity;

    if (kMessageModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
//        entity = [NSEntityDescription entityForName:[VSequence entityName] inManagedObjectContext:context];
    }
    else if (kNewsModeSelect == self.modeSelectControl.selectedSegmentIndex)
    {
//        entity = [NSEntityDescription entityForName:[VSequence entityName] inManagedObjectContext:context];
    }
    
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return fetchRequest;
}

#pragma mark - Cell Lifecycle

- (void)registerCells
{
    //Register cells here
}

#pragma mark - Refresh Lifecycle

- (void)refreshAction
{
//    SuccessBlock success = ^(NSArray* resultObjects)
    {
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }

        [self.refreshControl endRefreshing];
    };

//    FailBlock fail = ^(NSError* error)
    {
        [self.refreshControl endRefreshing];
//        VLog(@"Error on loadNextPage: %@", error);
    };

    //    [[[VObjectManager sharedManager] loadNextPageOfSequencesForCategory:[[VCategory findAllObjects] firstObject]
    //                                                           successBlock:success
    //                                                              failBlock:fail] start];
}

- (IBAction)modeSelected:(id)sender
{
    if (0 == [sender selectedSegmentIndex])
    {
        UIBarButtonItem*    searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(displaySearchBar:)];
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, searchButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(displaySearchBar:)];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Cells need to stop playing video for EVERY segue.
    
    if ([segue.identifier isEqualToString:@"toConversation"])
    {
//        VStreamsSubViewController *subview = (VStreamsSubViewController *)segue.destinationViewController;
//        UITableViewCell* cell = (UITableViewCell*)sender;
//        
//        VSequence *sequence = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
//        
//        subview.sequence = sequence;
    }
    else if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate = (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
