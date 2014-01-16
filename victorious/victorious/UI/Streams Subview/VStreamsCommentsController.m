//
//  VStreamsSubViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamsCommentsController.h"
#import "VLoginViewController.h"

#import "VComment.h"
#import "VSequence+Fetcher.h"
#import "VUser+RestKit.h"

#import "VObjectManager+Login.h"
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"

#import "VCommentCell.h"
#import "VSequencePlayerViewController.h"
#import "VThemeManager.h"
#import "BBlock.h"
#import "UIActionSheet+BBlock.h"
#import "VComposeViewController.h"
#import "VSequence+Fetcher.h"
#import "VAsset.h"

@import Social;

const   CGFloat     kCommentRowWithMediaHeight  =   320.0;
const   CGFloat     kCommentRowHeight           =   110;

@interface VStreamsCommentsController () <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, VComposeMessageDelegate>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSMutableArray* newlyReadComments;
@property (nonatomic, strong) VSequencePlayerViewController* sequencePlayer;
@end

static NSString* CommentCache = @"CommentCache";

@implementation VStreamsCommentsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadSequence];
    
    _newlyReadComments = [[NSMutableArray alloc] init];

    VLog(@"self.navigationController.delegate: %@", self.navigationController.delegate);
    
    [self.tableView registerNib:[UINib nibWithNibName:kCommentCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherCommentCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kOtherCommentCellIdentifier];

    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.composeViewController.delegate = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
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
    indicator.hidesWhenStopped = YES;
    
    SuccessBlock success = ^(NSArray *resultObjects) {
        
        [self fetchedResultsController];
        
        [self updatePredicate];
        
        [indicator stopAnimating];
        [indicator removeFromSuperview];
        
        [self setupSequencePlayer];
    };
    
    FailBlock fail = ^(NSError *error) {
        [indicator stopAnimating];
        [indicator removeFromSuperview];
//        UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Unable to Load Media" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
//        [alert show];
    };
    
    [[[VObjectManager sharedManager] loadNextPageOfCommentsForSequence:self.sequence
                                                          successBlock:success
                                                             failBlock:fail] start];
}

- (void) setupSequencePlayer
{
    _sequencePlayer = [[VSequencePlayerViewController alloc] initWithSequence:_sequence];
    
    [self.tableView reloadData]; //Need to reload to get rid of headers.
}

#pragma mark - IBActions

- (IBAction)refresh:(UIRefreshControl *)sender
{
    SuccessBlock success = ^(NSArray* resultObjects)
    {
        NSManagedObjectContext* context =  [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
        [context performBlockAndWait:^
         {
            NSError *error;
            if (![self.fetchedResultsController performFetch:&error] && error)
            {
                // Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
         }];
        
        [self.refreshControl endRefreshing];
    };
    
    FailBlock fail = ^(NSError* error)
    {
        [self.refreshControl endRefreshing];
        VLog(@"Error on loadNextPage: %@", error);
    };
    
    [[[VObjectManager sharedManager] loadNextPageOfCommentsForSequence:_sequence
                                                          successBlock:success
                                                             failBlock:fail] start];
}

- (IBAction)shareSequence:(id)sender
{
    if (![VObjectManager sharedManager].isAuthorized)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSURL* deepLink = [NSURL URLWithString:@"http://www.google.com"];
    UIImage* image = [UIImage imageNamed:@"avatar.jpg"];
    NSString* text = @"Some text";
    NSArray* itemsToShare = @[deepLink, image, text];

    UIActivityViewController*   activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare
                                                                                           applicationActivities:nil];
    activityViewController.modalTransitionStyle =   UIModalTransitionStyleCoverVertical;
    activityViewController.completionHandler    =   ^(NSString *activityType, BOOL completed)
    {
        if (completed)
        {
            //  send server
        }
    };
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)likeComment:(id)sender forEvent:(UIEvent *)event
{
    if (![VObjectManager sharedManager].isAuthorized)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    //    if (comment.vote = @"dislike")
    //    {
    //        [self unvoteComment:comment];
    //        return;
    //    }
    
    [[[VObjectManager sharedManager] likeComment:comment
                                   successBlock:^(NSArray *resultObjects) {
                                       //TODO:set upvote flag
                                       VLog(@"resultObjects: %@", resultObjects);
                                   }
                                      failBlock:^(NSError *error) {
                                          VLog(@"Failed to like comment %@", comment);
                                      }] start];
}

- (IBAction)dislikeComment:(id)sender forEvent:(UIEvent *)event
{
    if (![VObjectManager sharedManager].isAuthorized)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
//    if (comment.vote = @"dislike")
//    {
//        [self unvoteComment:comment];
//        return;
//    }
    
    [[[VObjectManager sharedManager] dislikeComment:comment
                                   successBlock:^(NSArray *resultObjects) {
                                       //TODO:set dislike flag)
                                       VLog(@"resultObjects: %@", resultObjects);
                                   }
                                      failBlock:^(NSError *error) {
                                          VLog(@"Failed to dislike comment %@", comment);
                                      }] start];
}

- (void)unvoteComment:(VComment*)comment
{
    [[[VObjectManager sharedManager] unvoteComment:comment
                                      successBlock:^(NSArray *resultObjects) {
                                          //TODO:update UI)
                                          VLog(@"resultObjects: %@", resultObjects);
                                      }
                                         failBlock:^(NSError *error) {
                                             VLog(@"Failed to dislike comment %@", comment);
                                         }] start];
}

- (IBAction)flagComment:(id)sender forEvent:(UIEvent *)event
{
    if (![VObjectManager sharedManager].isAuthorized)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    [[[VObjectManager sharedManager] flagComment:comment
                                       successBlock:^(NSArray *resultObjects)
                                       {
                                           //TODO:set flagged flag)
                                           VLog(@"resultObjects: %@", resultObjects);
                                       }
                                          failBlock:^(NSError *error)
                                          {
                                              VLog(@"Failed to flag comment %@", comment);
                                          }] start];
}

- (IBAction)addButtonAction:(id)sender
{

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
    VComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [comment.mediaUrl length] ? kCommentRowWithMediaHeight : kCommentRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
//    VComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    if([comment.user isEqualToUser:[VObjectManager sharedManager].mainUser])
//    {
//        cell = [self.tableView dequeueReusableCellWithIdentifier:kOtherCommentCellIdentifier forIndexPath:indexPath];
//    }else
//    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier forIndexPath:indexPath];
//    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Add
    VComment* comment = (VComment*)[_fetchedResultsController objectAtIndexPath:indexPath];
    //if(!comment.read)
    [_newlyReadComments addObject:[NSString stringWithFormat:@"%@", comment.remoteId]];
}


- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    VComment *comment = [self.fetchedResultsController objectAtIndexPath:theIndexPath];
    [(VCommentCell*)theCell setCommentOrMessage:comment];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([_sequence isVideo] && [[_sequence firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
    {
        return _sequencePlayer.view;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_sequence isVideo] && [[_sequence firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
    {
        return 160;
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBlockWeakSelf wself = self;
    VComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *reportTitle = NSLocalizedString(@"Report Inappropriate", @"Comment report inappropriate button");
    NSString *thumbUpTitle = NSLocalizedString(@"Thumbs Up", @"Comment thumbs up button");
    NSString *thumbDownTitle = NSLocalizedString(@"Thumbs Down", @"Comment thumbs down button");
    NSString *reply = NSLocalizedString(@"Reply", @"Comment reply button");
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc]
     initWithTitle:nil delegate:nil
     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
     destructiveButtonTitle:reportTitle otherButtonTitles:thumbUpTitle, thumbDownTitle, reply, nil];
    [actionSheet setCompletionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet)
     {
         if(actionSheet.cancelButtonIndex == buttonIndex)
         {
             return;
         }

         if(actionSheet.destructiveButtonIndex == buttonIndex)
         {
             [[[VObjectManager sharedManager] flagComment:comment
                                             successBlock:^(NSArray *resultObjects)
               {
                   //TODO:set flagged flag)
                   VLog(@"resultObjects: %@", resultObjects);
               }
                                                failBlock:^(NSError *error)
               {
                   VLog(@"Failed to flag comment %@", comment);
               }] start];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:thumbUpTitle])
         {
             [[[VObjectManager sharedManager] likeComment:comment
                                               successBlock:^(NSArray *resultObjects) {
                                                   //TODO:update UI)
                                                   VLog(@"resultObjects: %@", resultObjects);
                                               }
                                                  failBlock:^(NSError *error) {
                                                      VLog(@"Failed to dislike comment %@", comment);
                                                  }] start];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:thumbDownTitle])
         {
             [[[VObjectManager sharedManager] dislikeComment:comment
                                                successBlock:^(NSArray *resultObjects) {
                                                    //TODO:set dislike flag)
                                                    VLog(@"resultObjects: %@", resultObjects);
                                                }
                                                   failBlock:^(NSError *error) {
                                                       VLog(@"Failed to dislike comment %@", comment);
                                                   }] start];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:reply])
         {
             [wself.delegate streamsCommentsController:wself shouldReplyToUser:comment.user];
         }
     }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [actionSheet showInView:window];
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
    
    NSManagedObjectContext* context =  [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^
     {
        //We need to perform the fetch again
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error] && error)
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
     }];
    
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
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:NO];
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

#pragma mark - VComposeMessageDelegate

- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL
{
    
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0, 0, 24, 24);
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    SuccessBlock success = ^(NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
        [indicator stopAnimating];
        [self updatePredicate];
    };
    FailBlock fail = ^(NSError* error)
    {
        NSLog(@"%@", error);
        [indicator stopAnimating];
        
        UIAlertView*    alert   =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TranscodingMediaTitle", @"")
                                   message:NSLocalizedString(@"TranscodingMediaBody", @"")
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                         otherButtonTitles:nil];
        [alert show];
    };

    
    [[VObjectManager sharedManager] addCommentWithText:text
                                                   Data:data
                                         mediaExtension:mediaExtension
                                              mediaUrl:nil
                                             toSequence:_sequence
                                              andParent:nil
                                           successBlock:success
                                             failBlock:fail];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toComposeMessage"])
    {
//        ((VComposeMessageViewController *)segue.destinationViewController).delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{    
    //Whenever we leave this view we need to tell the server what was read.
    if ([VObjectManager sharedManager].isAuthorized && [_newlyReadComments count])
    {
        __block NSMutableArray* readComments = _newlyReadComments;
        [[[VObjectManager sharedManager] readComments:readComments
                                         successBlock:nil
                                            failBlock:^(NSError *error) {
                                                VLog(@"Warning: failed to mark following comments as read: %@", readComments);
                                            }] start];
    }
    _newlyReadComments = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"toComposeMessage"] && ![VObjectManager sharedManager].isAuthorized)
    {
        [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        return NO;
    }
    
    return YES;
}

@end
