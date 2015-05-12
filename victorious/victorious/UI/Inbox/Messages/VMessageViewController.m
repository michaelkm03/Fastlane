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
#import "UIImage+ImageEffects.h"
#import "VCommentTextAndMediaView.h"
#import "VConstants.h"
#import "VConversation.h"
#import "VMessageTableDataSource.h"
#import "VMessageViewController.h"
#import "VMessageCell.h"
#import "VMessageContainerViewController.h"
#import "VMessage+RestKit.h"
#import "VObjectManager.h"
#import "VPaginationManager.h"
#import "VUnreadMessageCountCoordinator.h"
#import "VUser+RestKit.h"
#import "VUserProfileViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VDefaultProfileImageView.h"
#import "UIStoryboard+VMainStoryboard.h"
#import "VDependencyManager+VUserProfile.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VMessageViewController () <VMessageTableDataDelegate>

@property (nonatomic, readwrite) VMessageTableDataSource *tableDataSource;
@property (nonatomic, strong)    VDependencyManager      *dependencyManager;
@property (nonatomic)            BOOL                     shouldScrollToBottom;
@property (nonatomic)            BOOL                     refreshFailed;

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
    [self.tableView registerNib:[UINib nibWithNibName:kVMessageCellNibName bundle:nil]
         forCellReuseIdentifier:kVMessageCellNibName];
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
                }
            }];
        }
        self.shouldScrollToBottom = YES;
    }

    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
}

- (void)tapped:(UITapGestureRecognizer *)tap
{
    // This clears any selectected text in a message cell when the background is tapped
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableDataSource beginLiveUpdates];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableDataSource endLiveUpdates];
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

#pragma mark - VMessageTableDataDelegate methods

- (UITableViewCell *)dataSource:(VMessageTableDataSource *)dataSource cellForMessage:(VMessage *)message atIndexPath:(NSIndexPath *)indexPath
{
    VMessageCell *cell = [dataSource.tableView dequeueReusableCellWithIdentifier:kVMessageCellNibName forIndexPath:indexPath];
    
    cell.timeLabel.text = [message.postedAt timeSince];
    cell.commentTextView.text = message.text;
    cell.profileImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    if ([message.sender isEqualToUser:[[VObjectManager sharedManager] mainUser]])
    {
        cell.profileImageOnRight = YES;
    }
    
    BOOL hasMedia = [message.thumbnailPath isKindOfClass:[NSString class]] && ![message.thumbnailPath isEqualToString:@""];
    if (hasMedia)
    {
        cell.commentTextView.hasMedia = YES;
        cell.commentTextView.mediaThumbnailView.hidden = NO;
        [cell.commentTextView.mediaThumbnailView sd_setImageWithURL:[NSURL URLWithString:message.thumbnailPath]];
        if ([message.mediaPath v_hasVideoExtension])
        {
            cell.commentTextView.onMediaTapped = [cell.commentTextView standardMediaTapHandlerWithMediaURL:[NSURL URLWithString:message.mediaPath] presentingViewController:self];
            cell.commentTextView.playIcon.hidden = NO;
        }
    }
    else
    {
        cell.commentTextView.mediaThumbnailView.hidden = YES;
    }
    
    NSURL *pictureURL = [NSURL URLWithString:message.sender.pictureUrl];
    if (pictureURL)
    {
        [cell.profileImageView setProfileImageURL:pictureURL];
    }
    cell.onProfileImageTapped = ^(void)
    {
        VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:message.sender];
        [self.navigationController pushViewController:profileViewController animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = [self.tableDataSource messageAtIndexPath:indexPath];
    BOOL hasMedia = [message.thumbnailPath isKindOfClass:[NSString class]] && ![message.thumbnailPath isEqualToString:@""];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) text:message.text withMedia:hasMedia];
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
}

@end
