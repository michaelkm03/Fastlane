//
//  VCommentsTableViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentsTableViewController.h"
#import "VTextAndMediaView.h"
#import "VRTCUserPostedAtFormatter.h"
#import "VDependencyManager+VScaffoldViewController.h"
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
#import <SDWebImage/UIImageView+WebCache.h>
#import "VTagStringFormatter.h"
#import "VTag.h"
#import "VUserTag.h"
#import "VTagSensitiveTextView.h"
#import "VHashtagStreamCollectionViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VUserProfile.h"
#import "UIView+AutoLayout.h"
#import "VNoContentView.h"
#import "VDependencyManager+VTracking.h"
#import "VTableViewStreamFocusHelper.h"
#import "VCommentMedia.h"
#import "VScrollPaginator.h"
#import "VVideoLightboxViewController.h"
#import "VLightboxTransitioningDelegate.h"
#import "victorious-Swift.h"
#import "VCommentTextAndMediaView.h"
#import "NSURL+MediaType.h"
#import "VImageLightboxViewController.h"

@import Social;

@interface VCommentsTableViewController () <VEditCommentViewControllerDelegate, VSwipeViewControllerDelegate, VCommentCellUtilitiesDelegate, VTagSensitiveTextViewDelegate, VScrollPaginatorDelegate, VCommentMediaTapDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) BOOL hasComments;
@property (nonatomic, assign) BOOL needsRefresh;
@property (nonatomic, strong) VTransitionDelegate *transitionDelegate;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentView *noContentView;
@property (nonatomic, strong) VTableViewStreamFocusHelper *focusHelper;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) NSMutableArray *reuseIdentifiers;

@end

@implementation VCommentsTableViewController

#pragma mark - VHasManagedDependencies conforming factory method

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VCommentsTableViewController *streamsCommentsController = [[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"comments"];
    streamsCommentsController.dependencyManager = dependencyManager;
    return streamsCommentsController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VSimpleModalTransition *modalTransition = [[VSimpleModalTransition alloc] init];
    self.transitionDelegate = [[VTransitionDelegate alloc] initWithTransition:modalTransition];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //This hides the seperators for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.needsRefresh = NO;
    
    self.noContentView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    [self.noContentView resetInitialAnimationState];
    self.noContentView.title = NSLocalizedString(@"NoCommentsTitle", @"");
    self.noContentView.message = NSLocalizedString(@"NoCommentsMessage", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noCommentIcon"];
    self.tableView.backgroundView = nil;
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    // Initialize our focus helper
    self.focusHelper = [[VTableViewStreamFocusHelper alloc] initWithTableView:self.tableView];
    
    self.reuseIdentifiers = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VTrackingManager sharedInstance] startEvent:VTrackingEventCommentsDidAppear];
    [self.tableView reloadData];
    
    if (self.needsRefresh)
    {
        [self.refreshControl beginRefreshing];
    }
    
    // Update cell focus
    [self.focusHelper updateFocus];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueCommentsView forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
    
    [[VTrackingManager sharedInstance] endEvent:VTrackingEventCommentsDidAppear];
    [[VTrackingManager sharedInstance] setValue:nil forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.focusHelper endFocusOnAllCells];
}

#pragma mark - Property Accessors

- (void)setFocusAreaInset:(UIEdgeInsets)focusAreaInset
{
    _focusAreaInset = focusAreaInset;
    self.focusHelper.focusAreaInsets = focusAreaInset;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.title = sequence.name;
    
    [self.tableView reloadData];
    
    self.needsRefresh = YES;
    [self refresh:self.refreshControl];
}

- (void)setHasComments:(BOOL)hasComments
{
    _hasComments = hasComments;
    if (!hasComments)
    {
        self.tableView.backgroundView = self.noContentView;
        self.noContentView.frame = self.tableView.bounds;
        [self.noContentView animateTransitionIn];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.backgroundView = nil;
        [self.noContentView resetInitialAnimationState];
        
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [self.focusHelper updateFocus];
                   });
}

#pragma mark - IBActions

- (IBAction)refresh:(UIRefreshControl *)sender
{
    RKManagedObjectRequestOperation *operation = [[VObjectManager sharedManager] loadCommentsOnSequence:self.sequence
                                                                                               pageType:VPageTypeFirst
                                                                                           successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
                                                  {
                                                      self.comments = [self.sequence.comments array];
                                                      
                                                      self.hasComments = self.comments.count > 0;
                                                      
                                                      self.needsRefresh = NO;
                                                      [self.tableView reloadData];
                                                      [self.refreshControl endRefreshing];
                                                      
                                                      // Give cells a moment to come on screen
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                                                     {
                                                                         [self.focusHelper updateFocus];
                                                                     });
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

- (void)shouldLoadNextPage
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
    return [VCommentCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) comment:comment];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VComment *comment = self.comments[indexPath.row];
    NSString *reuseIdentifier = [MediaAttachmentView reuseIdentifierForComment:comment];
    
    if (![self.reuseIdentifiers containsObject:reuseIdentifier])
    {
        [self.tableView registerNib:[UINib nibWithNibName:kVCommentCellNibName bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        [self.reuseIdentifiers addObject:reuseIdentifier];
    }
    
    VCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.timeLabel.text = [comment.postedAt timeSince];
    if (comment.realtime.integerValue < 0)
    {
        
        cell.usernameLabel.attributedText = [VRTCUserPostedAtFormatter formatRTCUserName:comment.user.name
                                                                   withDependencyManager:self.dependencyManager];
    }
    else
    {
        cell.usernameLabel.attributedText = [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:comment.user.name
                                                                                                    andPostedTime:comment.realtime
                                                                                            withDependencyManager:self.dependencyManager];
    }
    
    //Ugly, but only way I can think of to reliably update to proper string formatting per each cell
    NSDictionary *defaultStringAttributes = cell.textAndMediaView.textFont ? [VTextAndMediaView attributesForTextWithFont:cell.textAndMediaView.textFont] : [VTextAndMediaView attributesForText];
    NSMutableDictionary *tagStringAttributes = [[NSMutableDictionary alloc] initWithDictionary:defaultStringAttributes];
    tagStringAttributes[NSForegroundColorAttributeName] = [self.dependencyManager colorForKey:[VTagStringFormatter defaultDependencyManagerTagColorKey]];
    [cell.textAndMediaView setText:comment.text];
    [cell.textAndMediaView.textView setupWithDatabaseFormattedText:comment.text
                                                    tagAttributes:tagStringAttributes
                                                defaultAttributes:defaultStringAttributes
                                                andTagTapDelegate:self];
    
    [cell.textAndMediaView setComment:comment];
    [cell.textAndMediaView setDependencyManager:self.dependencyManager];
    cell.textAndMediaView.mediaTapDelegate = self;
    
    cell.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [cell.profileImageView setProfileImageURL:[NSURL URLWithString:comment.user.pictureUrl]];
    __weak typeof(self) welf = self;
    cell.onProfileImageTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [welf.dependencyManager userProfileViewControllerWithUser:comment.user];
        [welf.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Setup required for swipe-to-reveal utility buttons
    cell.commentCellUtilitiesController = [[VCommentCellUtilitesController alloc] initWithComment:comment cellView:cell delegate:cell permissions:self.sequence.permissions];
    cell.swipeViewController.cellDelegate = cell.commentCellUtilitiesController;
    cell.swipeViewController.controllerDelegate = self;
    cell.commentsUtilitiesDelegate = self;
    
    return cell;
}

- (void)tagSensitiveTextView:(VTagSensitiveTextView *)tagSensitiveTextView tappedTag:(VTag *)tag
{
    if ( [tag isKindOfClass:[VUserTag class]] )
    {
        //Tapped a user tag, show a profile view controller
        VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithRemoteId:((VUserTag *)tag).remoteId];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else
    {
        //Tapped a hashtag, show a hashtag view controller
        VHashtagStreamCollectionViewController *hashtagViewController = [self.dependencyManager hashtagStreamWithHashtag:[tag.displayString.string substringFromIndex:1]];
        [self.navigationController pushViewController:hashtagViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // End focus on this cell to stop video if there is one
    [self.focusHelper endFocusOnCell:cell];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update cell focus for videos
    [self.focusHelper updateFocus];
    [self.scrollPaginator scrollViewDidScroll:scrollView];
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

#pragma mark - Media Tap Delegate

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view
{
    VLightboxViewController *lightbox;
    if ([mediaURL v_hasImageExtension])
    {
        lightbox = [[VImageLightboxViewController alloc] initWithImage:image];
    }
    else
    {
        lightbox = [[VVideoLightboxViewController alloc] initWithPreviewImage:image videoURL:mediaURL];
        ((VVideoLightboxViewController *)lightbox).onVideoFinished = lightbox.onCloseButtonTapped;
        ((VVideoLightboxViewController *)lightbox).titleForAnalytics = @"Video Comment";
    }
    [VLightboxTransitioningDelegate addNewTransitioningDelegateToLightboxController:lightbox referenceView:view];
    
    __weak typeof(self) weakSelf = self;
    lightbox.onCloseButtonTapped = ^(void)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:lightbox animated:YES completion:nil];
}

@end
