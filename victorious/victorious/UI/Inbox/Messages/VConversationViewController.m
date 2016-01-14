//
//  VConversationViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NSDate+timeSince.h"
#import "NSURL+MediaType.h"
#import "VMessageTextAndMediaView.h"
#import "VConversationViewController.h"
#import "VMessageCell.h"
#import "VConversationContainerViewController.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VUser+RestKit.h"
#import "VUserProfileViewController.h"
#import "VDefaultProfileImageView.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VUserProfile.h"
#import "VLightboxTransitioningDelegate.h"
#import "VVideoLightboxViewController.h"
#import "VImageLightboxViewController.h"
#import "VTableViewStreamFocusHelper.h"
#import "victorious-Swift.h"

@interface VConversationViewController () <VCommentMediaTapDelegate, VCellWithProfileDelegate, VScrollPaginatorDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic) BOOL shouldScrollToBottom;
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
    
    self.noContentView = [VNoContentView noContentViewWithFrame:self.tableView.bounds];
    self.noContentView.dependencyManager = self.dependencyManager;
    self.noContentView.title = NSLocalizedString(@"NoMessagesTitle", @"");
    self.noContentView.message = NSLocalizedString(@"NoMessagesMessage", @"");
    self.noContentView.icon = [UIImage imageNamed:@"noMessagesIcon"];
}

- (void)viewDidLayoutSubviews
{
    if (self.shouldScrollToBottom)
    {
        self.shouldScrollToBottom = NO;
        [self scrollToBottomAnimated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (void)refresh
{
    [self.dataSource loadMessagesWithPageType:VPageTypeRefresh completion:^(NSError *_Nullable error)
     {
         if ( error != nil )
         {
             [self scrollToBottomAnimated:NO];
             [self.focusHelper updateFocus];
         }
         
         [self updateTableView];
         [self.focusHelper updateFocus];
     }];
    self.shouldScrollToBottom = YES;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, MAX(self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.bounds), 0)) animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#warning FIXME
    //[self.tableDataSource beginLiveUpdates];
    
    // Update cell focus
    [self.focusHelper updateFocus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#warning FIXME
    //[self.tableDataSource endLiveUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // End focus on cells
    [self.focusHelper endFocusOnAllCells];
}

- (void)updateTableView
{
    switch ( self.dataSource.state )
    {
        case DataSourceStateError:
        case DataSourceStateNoResults: {
            if ( self.tableView.backgroundView != self.noContentView )
            {
                self.tableView.backgroundView = self.noContentView;
                [self.noContentView resetInitialAnimationState];
                [self.noContentView animateTransitionIn];
            }
            break;
        }
            
        default:
            [UIView animateWithDuration:0.5f animations:^void
             {
                 self.tableView.backgroundView = nil;
             }];
            break;
    }
}

#pragma mark - Pagination

- (void)shouldLoadNextPage
{
    [self.dataSource loadMessagesWithPageType:VPageTypeNext completion:nil];
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
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                              {
                                  if ( [evaluatedObject isKindOfClass:[VUserProfileViewController class]] )
                                  {
                                      VUserProfileViewController *userProfile = evaluatedObject;
                                      return [userProfile.user isEqual:user];
                                  }
                                  return NO;
                              }];
    return [self.navigationController.viewControllers filteredArrayUsingPredicate:predicate].count > 0;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ![cell isKindOfClass:[VMessage class]] )
    {
        return;
    }
    VMessageCell *messageCell = (VMessageCell *)cell;
    messageCell.messageTextAndMediaView.mediaTapDelegate = self;
    messageCell.profileDelegate = self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = self.dataSource.visibleItems[ indexPath.row ];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) message:message];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // End focus on this cell to stop video if there is one
    [self.focusHelper endFocusOnCell:cell];
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
        VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:message.sender];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - VCommentMediaTapDelegate

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view
{
    // Preview image hasn't loaded yet, do not try and show lightbox
    if (image == nil)
    {
        return;
    }
    
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
