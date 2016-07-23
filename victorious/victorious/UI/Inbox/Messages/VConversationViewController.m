//
//  VConversationViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NSURL+MediaType.h"
#import "VConversation.h"
#import "VMessageTextAndMediaView.h"
#import "VConversationViewController.h"
#import "VMessageCell.h"
#import "VConversationContainerViewController.h"
#import "VUnreadMessageCountCoordinator.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VLightboxTransitioningDelegate.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VTableViewStreamFocusHelper.h"
#import "victorious-Swift.h"

@interface VConversationViewController () <VCommentMediaTapDelegate, VCellWithProfileDelegate, VScrollPaginatorDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSMutableArray *reuseIdentifiers;
@property (nonatomic, strong) VTableViewStreamFocusHelper *focusHelper;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;

@end

@implementation VConversationViewController

#pragma mark - VHasManagedDependencies conforming factory method

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VConversationViewController *messageViewController = (VConversationViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"messages"];
    messageViewController.dependencyManager = dependencyManager;
    return messageViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    self.reuseIdentifiers = [NSMutableArray new];
    
    self.dataSource = [[ConversationDataSource alloc] initWithConversation:self.conversation
                                                        dependencyManager:self.dependencyManager];
    [self.dataSource registerCells:self.tableView];
    self.dataSource.delegate = self;
    self.tableView.dataSource  = self.dataSource;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    // Initialize our focus helper
    self.focusHelper = [[VTableViewStreamFocusHelper alloc] initWithTableView:self.tableView];
    
    self.noContentView = [VNoContentView viewFromNibWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = NSLocalizedString(@"SAY HELLO!", @"");
    self.noContentView.message = NSLocalizedString(@"Send a message to start chatting with other members of the community.", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noMessagesIcon"];
    
    [self.dataSource loadMessagesWithPageType:VPageTypeFirst completion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         [self.focusHelper updateFocus];
         
         if ( !self.hasLoadedOnce )
         {
             [self.tableView reloadData];
             [self scrollToBottomAnimated:NO];
         }
         else
         {
             [self updateTableView];
         }
         self.hasLoadedOnce = YES;
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.hasLoadedOnce )
    {
        [self.dataSource refreshWithLocal:NO completion:nil];
    }
    
    [self updateTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginLiveUpdates];
    
    // Update cell focus
    [self.focusHelper updateFocus];
}

- (void)dealloc
{
    // Delete the conversation if it is empty, i.e. a user opened a new conversation but did not send any messages.
    NSInteger userID = self.conversation.user.remoteId.integerValue;
    [[[ConversationDeleteUnusedOperation alloc] initWithUserID:userID] queueWithCompletion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self endLiveUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // End focus on cells
    [self.focusHelper endFocusOnAllCells];
}

#pragma mark - Pagination

- (void)shouldLoadPreviousPage
{
    if ( [self.dataSource isLoading] )
    {
        return;
    }
    
    self.isLoadingNextPage = YES;
    [self.dataSource loadMessagesWithPageType:VPageTypeNext completion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
     {
         self.isLoadingNextPage = NO;
     }];
}

- (void)shouldLoadNextPage
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrollPaginator scrollViewDidScroll:scrollView];
}

#pragma mark - Property Accessors

- (void)setFocusAreaInset:(UIEdgeInsets)focusAreaInset
{
    _focusAreaInset = focusAreaInset;
    self.focusHelper.focusAreaInsets = focusAreaInset;
}

- (BOOL)navigationHistoryContainsUserProfileForUser:(VUser *)user
{
    return NO;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ![cell isKindOfClass:[VMessageCell class]] )
    {
        return;
    }
    VMessageCell *messageCell = (VMessageCell *)cell;
    messageCell.messageTextAndMediaView.mediaTapDelegate = self;
    messageCell.profileDelegate = self;
    messageCell.focusType = VFocusTypeStream;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ![cell isKindOfClass:[VMessageCell class]] )
    {
        return;
    }
    VMessageCell *messageCell = (VMessageCell *)cell;
    messageCell.focusType = VFocusTypeNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = self.dataSource.visibleItems[ indexPath.row ];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) message:message];
}

#pragma mark - VCellWithProfileDelegate

- (void)cellDidSelectProfile:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    VMessage *message = nil;
    if ( indexPath != nil )
    {
        message = self.dataSource.visibleItems[ indexPath.row ];
    }
    if ( message == nil )
    {
        return;
    }
    
    if ( [self navigationHistoryContainsUserProfileForUser:message.sender] )
    {
        UIViewController *profileViewController = [self.dependencyManager userProfileViewControllerFor:message.sender];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - VCommentMediaTapDelegate

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
