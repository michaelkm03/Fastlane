//
//  VStreamsSubViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamsSubViewController.h"
#import "VComment.h"

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"
#import "VCommentViewCell.h"

@interface VStreamsSubViewController ()
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@end

static NSString* CommentCache = @"CommentCache";

@implementation VStreamsSubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadSequence];
    
    //TODO: remove the "Add a ton of comments" function when I'm done testing
    //[self DOSAttackServer:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSequence:(VSequence *)sequence{
    _sequence = sequence;
    self.title = sequence.name;
}

- (void)loadSequence
{
    //Load new sequence
    __block UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] init];
    [self.view addSubview:indicator];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    SuccessBlock success = ^(NSArray *resultObjects) {
        
        [self fetchedResultsController];
        
        [self updatePredicate];
        
        [indicator stopAnimating];
        [indicator removeFromSuperview];
    };
    
    FailBlock fail = ^(NSError *error) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Unable to Load Media" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
        [alert show];
    };
    
    [[[VObjectManager sharedManager] loadFullDataForSequence:_sequence
                                                successBlock:success
                                                   failBlock:fail] start];
}

-(void)DOSAttackServer:(int)number
{
    if (number > 200)
        return;
    
    SuccessBlock success;
    success = ^(NSArray* objects)
    {
        [self DOSAttackServer:number+1];
    };
    NSString* text = [NSString stringWithFormat:@"Spam %i", number];
    
    [[[VObjectManager sharedManager] addCommentWithText:text
                                                  Data:nil
                                        mediaExtension:nil
                                            toSequence:_sequence
                                             andParent:nil
                                          successBlock:success
                                             failBlock:nil] start];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
    
    SuccessBlock success = ^(NSArray* resultObjects) {
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self.refreshControl endRefreshing];
    };
    
    FailBlock fail = ^(NSError* error) {
        [self.refreshControl endRefreshing];
        VLog(@"Error on loadNextPage: %@", error);
    };
    
    [[[VObjectManager sharedManager] loadNextPageOfCommentsForSequence:_sequence
                                                          successBlock:success
                                                             failBlock:fail] start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    VCommentViewCell *cell = (VCommentViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    VComment *info = [self.fetchedResultsController objectAtIndexPath:theIndexPath];
    
    theCell.textLabel.text = info.text;
    theCell.imageView.image = [UIImage imageNamed:@"avatar.jpg"];
}

#pragma mark - NSFetchedResultsControllers

- (void)updatePredicate
{
    //We must clear the cache before modifying anything.
    [NSFetchedResultsController deleteCacheWithName:CommentCache];
    
    NSFetchRequest* fetchRequest = self.fetchedResultsController.fetchRequest;
    
    //TODO: apply filter predicate
    
    NSPredicate* sequenceFilter = [NSPredicate predicateWithFormat:@"sequenceId == %@", _sequence.remoteId];
    [fetchRequest setPredicate:sequenceFilter];
    
    //We need to perform the fetch again
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
	}
    
    //Then reload the data
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [self fetchRequestForContext:context];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:CommentCache];
        self.fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[VComment entityName] inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];
    
    return fetchRequest;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you w	ill often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
