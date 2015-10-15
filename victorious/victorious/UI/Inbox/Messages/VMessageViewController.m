//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "MBProgressHUD.h"
#import "NSDate+timeSince.h"
#import "NSURL+MediaType.h"
#import "VMessageTextAndMediaView.h"
#import "VMessageTableDataSource.h"
#import "VMessageViewController.h"
#import "VMessageCell.h"
#import "VMessageContainerViewController.h"
#import "VObjectManager.h"
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

@interface VMessageViewController () <VMessageTableDataDelegate, VCommentMediaTapDelegate>

@property (nonatomic, readwrite) VMessageTableDataSource *tableDataSource;
@property (nonatomic, strong)    VDependencyManager      *dependencyManager;
@property (nonatomic)            BOOL                     shouldScrollToBottom;
@property (nonatomic)            BOOL                     refreshFailed;
@property (nonatomic, strong) NSMutableArray *reuseIdentifiers;
@property (nonatomic, strong) VTableViewStreamFocusHelper *focusHelper;

@end

@implementation VMessageViewController

#pragma mark - VHasManagedDependencies conforming factory method

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VMessageViewController *messageViewController = (VMessageViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:@"messages"];
    messageViewController.dependencyManager = dependencyManager;
    return messageViewController;
}

- (void)setOtherUser:(VUser *)otherUser
{
    _otherUser = otherUser;
    if ([self isViewLoaded])
    {
        self.tableDataSource.otherUser = otherUser;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.reuseIdentifiers = [NSMutableArray new];
    
    // Initialize our focus helper
    self.focusHelper = [[VTableViewStreamFocusHelper alloc] initWithTableView:self.tableView];
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
    
    if (!self.tableDataSource)
    {
        self.tableDataSource = [[VMessageTableDataSource alloc] initWithObjectManager:[VObjectManager sharedManager]];
        self.tableDataSource.otherUser = self.otherUser;
        self.tableDataSource.tableView = self.tableView;
        self.tableDataSource.delegate = self;
        self.tableDataSource.messageCountCoordinator = self.messageCountCoordinator;
        
        __weak typeof(self) weakSelf = self;
        [self.tableDataSource setAfterUpdate:^
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                [strongSelf.focusHelper updateFocus];
                            });
         }];
    }
    self.tableView.dataSource = self.tableDataSource;
    
    if (self.shouldRefreshOnAppearance)
    {
        self.refreshFailed = NO;
        self.shouldRefreshOnAppearance = NO;
        if (!self.tableDataSource.isLoading)
        {
            VMessageContainerViewController *container = (VMessageContainerViewController *)self.parentViewController;
            container.busyView.hidden = NO;
            [self.tableDataSource refreshWithCompletion:^(NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                 {
                     container.busyView.hidden = YES;
                     if (error)
                     {
                         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container.view animated:YES];
                         hud.mode = MBProgressHUDModeText;
                         hud.labelText = NSLocalizedString(@"ConversationLoadError", @"");
                         [hud hide:YES afterDelay:3.0];
                         self.refreshFailed = YES;
                     }
                     else
                     {
                         [self scrollToBottomAnimated:NO];
                         [self.focusHelper updateFocus];
                     }
                 });
                 
             }];
        }
        self.shouldScrollToBottom = YES;
    }
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        // This clears any selectected text in a message cell when the background is tapped
        [self.tableView reloadData];
        [self.focusHelper updateFocus];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableDataSource beginLiveUpdates];
    
    // Update cell focus
    [self.focusHelper updateFocus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableDataSource endLiveUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // End focus on cells
    [self.focusHelper endFocusOnAllCells];
}

- (void)loadNextPageAction
{
    [self.tableDataSource loadNextPageWithCompletion:^(NSError *error)
    {
        if (error)
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"ConversationLoadError", @"");
            [hud hide:YES afterDelay:3.0];
            self.refreshFailed = YES;
        }
    }];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointMake(0, MAX(self.tableView.contentSize.height + self.tableView.contentInset.top + self.tableView.contentInset.bottom - CGRectGetHeight(self.tableView.bounds), 0)) animated:animated];
}

#pragma mark - Property Accessors

- (void)setFocusAreaInset:(UIEdgeInsets)focusAreaInset
{
    _focusAreaInset = focusAreaInset;
    self.focusHelper.focusAreaInsets = focusAreaInset;
}

#pragma mark - VMessageTableDataDelegate methods

- (UITableViewCell *)dataSource:(VMessageTableDataSource *)dataSource cellForMessage:(VMessage *)message atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [MediaAttachmentView reuseIdentifierForMessage:message];
    
    if (![self.reuseIdentifiers containsObject:reuseIdentifier])
    {
        [self.tableView registerNib:[UINib nibWithNibName:kVMessageCellNibName bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        [self.reuseIdentifiers addObject:reuseIdentifier];
    }
    
    VMessageCell *cell = [dataSource.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.timeLabel.text = [message.postedAt timeSince];
    
    cell.messageTextAndMediaView.text = message.text;
    [cell.messageTextAndMediaView setMessage:message];

    cell.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    if ([message.sender isEqualToUser:[[VObjectManager sharedManager] mainUser]])
    {
        cell.profileImageOnRight = YES;
    }
    
    cell.messageTextAndMediaView.mediaTapDelegate = self;
    
    NSURL *pictureURL = [NSURL URLWithString:message.sender.pictureUrl];
    if (pictureURL)
    {
        [cell.profileImageView setProfileImageURL:pictureURL];
    }
    cell.onProfileImageTapped = ^(void)
    {
        if ( [self navigationHistoryContainsUserProfileForUser:message.sender] )
        {
            VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:message.sender];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = [self.tableDataSource messageAtIndexPath:indexPath];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) message:message];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // End focus on this cell to stop video if there is one
    [self.focusHelper endFocusOnCell:cell];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.refreshFailed &&
        scrollView.contentOffset.y < CGRectGetHeight(scrollView.bounds) &&
        ![self.tableDataSource isLoading] &&
        [self.tableDataSource areMorePagesAvailable])
    {
        [self loadNextPageAction];
    }
    
    [self.focusHelper updateFocus];
}

#pragma mark - Media Tap Delegate

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
