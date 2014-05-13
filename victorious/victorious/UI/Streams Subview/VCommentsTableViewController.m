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

#import "VObjectManager+SequenceFilters.h"
#import "VObjectManager+Comment.h"

#import "UIActionSheet+VBlocks.h"
#import "NSString+VParseHelp.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIImageView+Blurring.h"

#import "UIImage+ImageCreation.h"


@import Social;

@interface VCommentsTableViewController () //<UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray* newlyReadComments;
@property (nonatomic, strong) NSArray* sortedComments;
@property (nonatomic, strong) UIImageView* backgroundImageView;

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

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self sortComments];
}

- (void)setSequence:(VSequence *)sequence
{
    self.sortedComments = [sequence.comments allObjects];
    [self.tableView reloadData];
    
    _sequence = sequence;
    
    self.title = sequence.name;
    
    if (![self.sortedComments count]) //If we don't have comments, try to pull more.
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
    //If theres no sorted comments, this is our first batch so animate in.
    if (![self.sortedComments count])
    {
        [self sortCommentsByDate];

        __block CGRect frame = self.view.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame);
        self.view.frame = frame;
        
        [UIView animateWithDuration:1.5
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:
         ^{
             frame.origin.x = 0;
             self.view.frame = frame;
         }
                         completion:nil];
    }
    else
    {
        [self sortCommentsByDate];
    }
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
    VCommentFilter* filter = [[VObjectManager sharedManager] commentFilterForSequence:self.sequence];
    RKManagedObjectRequestOperation* operation = [[VObjectManager sharedManager]
                                                  loadNextPageOfCommentFilter:filter
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                  {
                                                      [self performSelector:@selector(sortComments) withObject:nil afterDelay:.5f];
                                                      [self.refreshControl endRefreshing];
                                                  }
                                                  failBlock:^(NSOperation* operation, NSError* error)
                                                  {
                                                      [self.refreshControl endRefreshing];
                                                  }];
    
    if (operation)
    {
        [self.refreshControl beginRefreshing];
    }
}

- (void)loadNextPageAction
{
    VCommentFilter* filter = [[VObjectManager sharedManager] commentFilterForSequence:self.sequence];
    RKManagedObjectRequestOperation* operation = [[VObjectManager sharedManager]
                                                  loadNextPageOfCommentFilter:filter
                                                  successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
                                                  {
                                                      [self sortComments];
//                                                      [self.bottomRefreshIndicator stopAnimating];
                                                  }
                                                  failBlock:^(NSOperation* operation, NSError* error)
                                                  {
//                                                      [self.bottomRefreshIndicator stopAnimating];
                                                  }];
    
    if (operation)
    {
//        [self.bottomRefreshIndicator startAnimating];
    }
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

    CGSize textSize = [VCommentCell frameSizeForMessageText:comment.text];
    CGFloat height = textSize.height;
    CGFloat yOffset = !comment.mediaUrl || [comment.mediaUrl isEmpty] ? kCommentCellYOffset : kMediaCommentCellYOffset;
    height = MAX(height + yOffset, kMinCellHeight);

    return height;
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
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment* comment = (VComment*)[self.sortedComments objectAtIndex:indexPath.row];
    [self.newlyReadComments addObject:[NSString stringWithFormat:@"%@", comment.remoteId]];

}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    NSString *reportTitle = NSLocalizedString(@"Report Inappropriate", @"Comment report inappropriate button");
    NSString *thumbUpTitle = NSLocalizedString(@"Thumbs Up", @"Comment thumbs up button");
    NSString *thumbDownTitle = NSLocalizedString(@"Thumbs Down", @"Comment thumbs down button");
    NSString *reply = NSLocalizedString(@"Reply", @"Comment reply button");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
                                                       onCancelButton:nil
                                               destructiveButtonTitle:reportTitle
                                                  onDestructiveButton:^(void)
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
                                           otherButtonTitlesAndBlocks:thumbUpTitle, ^(void)
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
    },
                                  thumbDownTitle, ^(void)
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
    },
                                  reply, ^(void)
    {
        [self.delegate streamsCommentsController:self shouldReplyToUser:comment.user];
    },
                                  nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [actionSheet showInView:window];
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

@end
