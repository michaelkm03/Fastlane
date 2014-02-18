//
//  VStreamsSubViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentsTableViewController.h"
#import "VConstants.h"
#import "VThemeManager.h"

#import "VLoginViewController.h"
#import "VCommentCell.h"

#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"

#import "UIActionSheet+BBlock.h"
#import "NSString+VParseHelp.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

@import Social;

const   CGFloat     kCommentRowWithMediaHeight  =   320.0;
const   CGFloat     kCommentRowHeight           =   110;

@interface VCommentsTableViewController () //<UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray* newlyReadComments;
@property (nonatomic, strong) NSArray* sortedComments;

@end

static NSString* CommentCache = @"CommentCache";

@implementation VCommentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCommentCellIdentifier bundle:nil]
         forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherCommentCellIdentifier bundle:nil]
         forCellReuseIdentifier:kOtherCommentCellIdentifier];

    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self sortComments];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    self.title = sequence.name;
    
    if (![self.sequence.comments count]) //If we don't have comments, try to pull more.
        [self refresh:nil];
    else
        [self sortComments];
}

- (NSMutableArray *)newlyReadComments
{
    if (_newlyReadComments == nil)
    {
        _newlyReadComments = [[NSMutableArray alloc] init];
    }
    return _newlyReadComments;
}

#pragma mark - Comment Sorters
- (void)sortComments
{
    //TODO: choose the right sort based on filter
    [self sortCommentsByDate];
}

- (void)sortCommentsByDate
{
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
    self.sortedComments = [[self.sequence.comments allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (void)sortCommentsByFriends
{
    //TODO: add sort by friends
}

- (void)sortCommentsByPopular
{
    //TODO: add sort by popular
}

#pragma mark - IBActions

- (IBAction)refresh:(UIRefreshControl *)sender
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self sortComments];
        
        [self.refreshControl endRefreshing];
    };
    
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        [self.refreshControl endRefreshing];
        VLog(@"Error on loadNextPage: %@", error);
    };
    
    [[VObjectManager sharedManager] loadNextPageOfCommentsForSequence:self.sequence
                                                          successBlock:success
                                                             failBlock:fail];
}

- (IBAction)shareSequence:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
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
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    
    //    if (comment.vote = @"dislike")
    //    {
    //        [self unvoteComment:comment];
    //        return;
    //    }
    
    [[VObjectManager sharedManager] likeComment:comment
                                   successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                   {
                                       //TODO:set upvote flag
                                       VLog(@"resultObjects: %@", resultObjects);
                                   }
                                      failBlock:^(NSOperation* operation, NSError* error)
                                      {
                                          VLog(@"Failed to like comment %@", comment);
                                      }];
}

- (IBAction)dislikeComment:(id)sender forEvent:(UIEvent *)event
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    
//    if (comment.vote = @"dislike")
//    {
//        [self unvoteComment:comment];
//        return;
//    }
    
    [[VObjectManager sharedManager] dislikeComment:comment
                                      successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                   {
                                       //TODO:set dislike flag)
                                       VLog(@"resultObjects: %@", resultObjects);
                                   }
                                         failBlock:^(NSOperation* operation, NSError* error)
                                      {
                                          VLog(@"Failed to dislike comment %@", comment);
                                      }];
}

- (void)unvoteComment:(VComment*)comment
{
    [[VObjectManager sharedManager] unvoteComment:comment
                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                      {
                                          //TODO:update UI)
                                          VLog(@"resultObjects: %@", resultObjects);
                                      }
                                        failBlock:^(NSOperation* operation, NSError* error)
                                         {
                                             VLog(@"Failed to dislike comment %@", comment);
                                         }];
}

- (IBAction)flagComment:(id)sender forEvent:(UIEvent *)event
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    
    [[VObjectManager sharedManager] flagComment:comment
                                   successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                       {
                                           //TODO:set flagged flag)
                                           VLog(@"resultObjects: %@", resultObjects);
                                       }
                                      failBlock:^(NSOperation* operation, NSError* error)
                                          {
                                              VLog(@"Failed to flag comment %@", comment);
                                          }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sortedComments count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    return [comment.mediaUrl length] ? kCommentRowWithMediaHeight : kCommentRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment* comment = (VComment*)[self.sortedComments objectAtIndex:indexPath.row];
    CGFloat yOffset = [comment.mediaUrl length] ? kMediaCommentCellYOffset : kCommentCellYOffset;

    return [comment.text heightForViewWidth:self.tableView.frame.size.width
                              andAttributes:nil] + yOffset;
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
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    [(VCommentCell*)cell setCommentOrMessage:comment];
    ((VCommentCell*)cell).parentTableViewController = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Add
    VComment* comment = (VComment*)[self.sortedComments objectAtIndex:indexPath.row];
    //if(!comment.read)
    [self.newlyReadComments addObject:[NSString stringWithFormat:@"%@", comment.remoteId]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
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
             [[VObjectManager sharedManager] flagComment:comment
                                            successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
               {
                   //TODO:set flagged flag)
                   VLog(@"resultObjects: %@", resultObjects);
               }
                                                failBlock:^(NSOperation* operation, NSError* error)
               {
                   VLog(@"Failed to flag comment %@", comment);
               }];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:thumbUpTitle])
         {
             [[VObjectManager sharedManager] likeComment:comment
                                               successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                               {
                                                   //TODO:update UI)
                                                   VLog(@"resultObjects: %@", resultObjects);
                                               }
                                                  failBlock:^(NSOperation* operation, NSError* error)
                                                  {
                                                      VLog(@"Failed to dislike comment %@", comment);
                                                  }];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:thumbDownTitle])
         {
             [[VObjectManager sharedManager] dislikeComment:comment
                                                successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                {
                                                    //TODO:set dislike flag)
                                                    VLog(@"resultObjects: %@", resultObjects);
                                                }
                                                   failBlock:^(NSOperation* operation, NSError* error)
                                                   {
                                                       VLog(@"Failed to dislike comment %@", comment);
                                                   }];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:reply])
         {
             [self.delegate streamsCommentsController:self shouldReplyToUser:comment.user];
         }
     }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [actionSheet showInView:window];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
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
    if ([VObjectManager sharedManager].mainUser && [self.newlyReadComments count])
    {
        __block NSMutableArray* readComments = self.newlyReadComments;
        [[VObjectManager sharedManager] readComments:readComments
                                         successBlock:nil
                                            failBlock:^(NSOperation* operation, NSError* error)
                                            {
                                                VLog(@"Warning: failed to mark following comments as read: %@", readComments);
                                            }];
    }
    self.newlyReadComments = nil;
    [super viewWillDisappear:animated];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"toComposeMessage"] && ![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return NO;
    }
    
    return YES;
}

#pragma mark - VKeyboardBarDelegate
- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL
{
    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0, 0, 24, 24);
    indicator.hidesWhenStopped = YES;
    [self.view addSubview:indicator];
    indicator.center = self.view.center;
    [indicator startAnimating];
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSLog(@"%@", resultObjects);
        [indicator stopAnimating];
        [(VCommentsTableViewController*)self sortComments];
    };
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        if (error.code == 5500)
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
        }
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


@end
