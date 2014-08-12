//
//  VStreamsSubViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VCommentsTableViewController.h"
#import "VCommentTextAndMediaView.h"
#import "VConstants.h"
#import "VThemeManager.h"

#import "VLoginViewController.h"
#import "VCommentCell.h"

#import "VObjectManager+Pagination.h"
#import "VObjectManager+Comment.h"
#import "VUser.h"
#import "VUserProfileViewController.h"

#import "UIActionSheet+VBlocks.h"
#import "NSDate+timeSince.h"
#import "NSString+VParseHelp.h"
#import "NSURL+MediaType.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VComment+Fetcher.h"
#import "VAsset.h"

#import "UIImageView+Blurring.h"

#import "UIImage+ImageCreation.h"

#import "VNoContentView.h"


@import Social;

@interface VCommentsTableViewController ()

@property (nonatomic, strong) NSMutableArray* newlyReadComments;
@property (nonatomic, strong) NSArray* sortedComments;
@property (nonatomic, strong) UIImageView* backgroundImageView;

@end

static NSString* CommentCache           = @"CommentCache";

@implementation VCommentsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVCommentCellNibName bundle:nil]
         forCellReuseIdentifier:kVCommentCellNibName];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //This hides the seperators for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"Comments"];
    [self sortComments];
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self setHasComments:self.sequence.commentCount.integerValue];
    
    self.title = sequence.name;
    
    [self sortComments];
    
    if (![self.sortedComments count]) //If we don't have comments, try to pull more.
        [self refresh:self.refreshControl];
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
    [self.sequence.managedObjectContext refreshObject:self.sequence mergeChanges:YES];
    self.sortedComments = [self.sequence.comments allObjects];
    //If theres no sorted comments, this is our first batch so animate in.
    if (![self.sortedComments count])
    {
        [self sortCommentsByDate];

        //Only do the animation if we have comments.
        if (![self.sortedComments count])
            return;
        
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

- (void)setHasComments:(BOOL)hasComments
{
    if (!hasComments)
    {
        VNoContentView* noCommentsView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = noCommentsView;
        noCommentsView.titleLabel.text = NSLocalizedString(@"NoCommentsTitle", @"");
        noCommentsView.messageLabel.text = NSLocalizedString(@"NoCommentsMessage", @"");
        noCommentsView.iconImageView.image = [UIImage imageNamed:@"noCommentIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
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
                                                      [self performSelector:@selector(sortComments) withObject:nil afterDelay:.5f];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sortedComments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment* comment = (VComment*)[self.sortedComments objectAtIndex:indexPath.row];
    return [VCommentCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) text:comment.text withMedia:comment.hasMedia];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kVCommentCellNibName forIndexPath:indexPath];
    VComment *comment = [self.sortedComments objectAtIndex:indexPath.row];
    
    cell.timeLabel.text = [comment.postedAt timeSince];
    cell.usernameLabel.text = comment.user.name;
    cell.commentTextView.text = comment.text;
    if (comment.hasMedia)
    {
        cell.commentTextView.mediaThumbnailView.hidden = NO;
        [cell.commentTextView.mediaThumbnailView setImageWithURL:comment.previewImageURL];
        if ([comment.mediaUrl isKindOfClass:[NSString class]] && [comment.mediaUrl v_hasVideoExtension])
        {
            cell.commentTextView.onMediaTapped = [cell.commentTextView standardMediaTapHandlerWithMediaURL:[NSURL URLWithString:comment.mediaUrl] presentingViewController:self];
            cell.commentTextView.playIcon.hidden = NO;
        }
    }
    else
    {
        cell.commentTextView.mediaThumbnailView.hidden = YES;
    }
    
    NSURL *pictureURL = [NSURL URLWithString:comment.user.pictureUrl];
    if (pictureURL)
    {
        [cell.profileImageView setImageWithURL:pictureURL];
    }
    cell.onProfileImageTapped = ^(void)
    {
        VUserProfileViewController* profileViewController = [VUserProfileViewController userProfileWithUser:comment.user];
        [self.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
             VLog(@"resultObjects: %@", resultObjects);
             
             UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                    message:NSLocalizedString(@"ReportCommentMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];

         }
                                          failBlock:^(NSOperation* operation, NSError* error)
         {
             VLog(@"Failed to flag comment %@", comment);
             
             //TODO: we may want to remove this later.
             UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                    message:NSLocalizedString(@"ReportCommentMessage", @"")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                          otherButtonTitles:nil];
             [alert show];

         }];
    }
                                           otherButtonTitlesAndBlocks:
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
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
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
