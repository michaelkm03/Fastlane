//
//  VStreamsSubViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentsTableViewController.h"
#import "VCommentTextAndMediaView.h"
#import "VThemeManager.h"
#import "VRTCUserPostedAtFormatter.h"

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
#import "VDefaultProfileImageView.h"

#import "VEditCommentViewController.h"
#import "VTransitionDelegate.h"

#import "VTagStringFormatter.h"

@import Social;

@interface VCommentsTableViewController () <VEditCommentViewControllerDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL hasComments;
@property (nonatomic, assign) BOOL needsRefresh;

@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;

@property (nonatomic, strong) NSArray *comments;

@end

@implementation VCommentsTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VSimpleModalTransition *modalTransition = [[VSimpleModalTransition alloc] init];
    self.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:modalTransition];
    
    [self.tableView registerNib:[UINib nibWithNibName:kVCommentCellNibName bundle:nil]
         forCellReuseIdentifier:kVCommentCellNibName];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //This hides the seperators for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.needsRefresh = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCommentsDidAppear];
    [self.tableView reloadData];
    
    if (self.needsRefresh)
    {
        [self.refreshControl beginRefreshing];
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.8f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
        {
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.bounds.size.height);
        } completion:nil];
    }
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;

    [self setHasComments:self.sequence.commentCount.integerValue];
    
    self.title = sequence.name;
    
    [self.tableView reloadData];
    
    if (self.hasComments) //If we don't have comments, try to pull more.
    {
        self.needsRefresh = YES;
        [self refresh:self.refreshControl];
    }
    else
    {
        self.needsRefresh = NO;
    }
}

- (void)setHasComments:(BOOL)hasComments
{
    _hasComments = hasComments;
    if (!hasComments)
    {
        VNoContentView *noCommentsView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
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
    self.comments = [self.sequence.comments array];
}

- (void)setComments:(NSArray *)comments
{
    NSArray *sortedComments = [comments sortedArrayUsingComparator:^NSComparisonResult(VComment *comment1, VComment *comment2)
                               {
                                   return [comment2.postedAt compare:comment1.postedAt];
                               }];
    _comments = sortedComments;
}

#pragma mark - Public Mehtods

- (void)addedNewComment:(VComment *)comment
{
    [self setHasComments:YES];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

#pragma mark - IBActions

- (IBAction)refresh:(UIRefreshControl *)sender
{
    RKManagedObjectRequestOperation *operation = [[VObjectManager sharedManager] loadCommentsOnSequence:self.sequence
                                                                                               pageType:VPageTypeFirst
                                                                                           successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
                                                  {
                                                      self.comments = [self.sequence.comments array];
                                                      self.needsRefresh = NO;
                                                      [self.tableView reloadData];
                                                      [self.refreshControl endRefreshing];
                                                  } failBlock:^(NSOperation *operation, NSError *error)
                                                  {
                                                      self.needsRefresh = NO;
                                                      [self.refreshControl endRefreshing];
                                                  }];
    if (!operation)
    {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Pagination

- (void)loadNextPageAction
{
    [[VObjectManager sharedManager] loadCommentsOnSequence:self.sequence
                                                  pageType:VPageTypeNext
                                              successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         self.comments = [self.sequence.comments array];
         [self.tableView reloadData];
     }
                                                 failBlock:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment *comment = (VComment *)self.comments[indexPath.row];
    return [VCommentCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds)
                                             text:comment.text
                                        withMedia:comment.hasMedia];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kVCommentCellNibName forIndexPath:indexPath];
    VComment *comment = self.comments[indexPath.row];
    
    
    cell.timeLabel.text = [comment.postedAt timeSince];
    if (comment.realtime.integerValue < 0)
    {
        
        cell.usernameLabel.attributedText = [VRTCUserPostedAtFormatter formatRTCUserName:comment.user.name];
    }
    else
    {
        cell.usernameLabel.attributedText = [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:comment.user.name
                                                                                      andPostedTime:comment.realtime];
    }
    
    //Ugly, but only way I can think of to reliably update to proper string formatting per each cell
    NSDictionary *defaultStringAttributes = cell.commentTextView.textFont ? [VCommentTextAndMediaView attributesForTextWithFont:cell.commentTextView.textFont] : [VCommentTextAndMediaView attributesForText];
    NSMutableDictionary *tagStringAttributes = [[NSMutableDictionary alloc] initWithDictionary:defaultStringAttributes];
    [tagStringAttributes setObject:[[VThemeManager sharedThemeManager] themedColorForKey:[VTagStringFormatter defaultThemeManagerTagColorKey]] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *formattedCommentText = [[NSMutableAttributedString alloc] initWithString:comment.text attributes:defaultStringAttributes];
    [VTagStringFormatter tagDictionaryFromFormattingAttributedString:formattedCommentText withTagStringAttributes:tagStringAttributes andDefaultStringAttributes:defaultStringAttributes];
    cell.commentTextView.attributedText = formattedCommentText;
    if (comment.hasMedia)
    {
        cell.commentTextView.hasMedia = YES;
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
        cell.commentTextView.hasMedia = NO;
    }
    
    [cell.profileImageView setProfileImageURL:[NSURL URLWithString:comment.user.pictureUrl]];
    cell.onProfileImageTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:comment.user];
        [self.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Setup required for swipe-to-reveal utility buttons
    cell.commentCellUtilitiesController = [[VCommentCellUtilitesController alloc] initWithComment:comment cellView:cell delegate:cell];
    cell.swipeViewController.cellDelegate = cell.commentCellUtilitiesController;
    cell.swipeViewController.controllerDelegate = self;
    cell.commentsUtilitiesDelegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventCommentsDidAppear];
}

#pragma mark - VSwipeViewControllerDelegate

- (UIColor *)backgroundColorForGutter
{
    return [UIColor colorWithWhite:0.96f alpha:1.0f];
}

- (void)cellWillShowUtilityButtons:(UIView *)cellView
{
    // Close any other cells showing utility buttons
    
    for ( VCommentCell *cell in self.tableView.visibleCells )
    {
        if ( [cell isKindOfClass:[VCommentCell class]] && cellView != cell )
        {
            [cell.swipeViewController hideUtilityButtons];
        }
    }
}

#pragma mark - VCommentCellUtilitiesDelegate

- (void)commentRemoved:(VComment *)comment
{
    NSUInteger index = [self.comments indexOfObject:comment];
    NSMutableArray *updatedComments = [self.comments mutableCopy];
    [updatedComments removeObjectAtIndex:index];
    self.comments = [NSArray arrayWithArray:updatedComments];
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:index inSection:0] ];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)editComment:(VComment *)comment
{
    VEditCommentViewController *editViewController = [VEditCommentViewController instantiateFromStoryboardWithComment:comment];
    editViewController.transitioningDelegate = self.transitionDelegate;
    editViewController.delegate = self;
    [self presentViewController:editViewController animated:YES completion:nil];
}

- (void)didSelectActionRequiringLogin
{
    [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
}

#pragma mark - VEditCommentViewControllerDelegate

- (void)didFinishEditingComment:(VComment *)comment
{
    [self.comments enumerateObjectsUsingBlock:^(VComment *existingComment, NSUInteger idx, BOOL *stop)
     {
         if ( [existingComment.remoteId isEqualToNumber:comment.remoteId] )
         {
             [self dismissViewControllerAnimated:YES completion:^void
              {
                  [self.tableView beginUpdates];
                  NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:idx inSection:0];
                  [self.tableView reloadRowsAtIndexPaths:@[ indexPathToReload ] withRowAnimation:UITableViewRowAnimationAutomatic];
                  [self.tableView endUpdates];
              }];
             
             *stop = YES;
         }
     }];
}

@end
