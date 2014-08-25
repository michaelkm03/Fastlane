//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSDate+timeSince.h"
#import "NSString+VParseHelp.h"
#import "NSURL+MediaType.h"
#import "UIButton+VImageLoading.h"
#import "UIImage+ImageEffects.h"
#import "VCommentTextAndMediaView.h"
#import "VConstants.h"
#import "VConversation.h"
#import "VMessageTableDataSource.h"
#import "VMessageViewController.h"
#import "VMessageCell.h"
#import "VMessage+RestKit.h"
#import "VObjectManager.h"
#import "VPaginationManager.h"
#import "VThemeManager.h"
#import "VUser+RestKit.h"
#import "VUserProfileViewController.h"

@interface VMessageViewController () <VMessageTableDataDelegate>

@property (nonatomic, strong) VMessageTableDataSource *tableDataSource;

@end

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:kVMessageCellNibName bundle:nil]
         forCellReuseIdentifier:kVMessageCellNibName];

    self.tableDataSource = [[VMessageTableDataSource alloc] initWithUser:self.otherUser objectManager:[VObjectManager sharedManager]];
    self.tableDataSource.tableView = self.tableView;
    self.tableDataSource.delegate = self;
    self.tableView.dataSource = self.tableDataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (!self.tableDataSource.isLoading)
    {
        [self.tableDataSource refreshWithCompletion:^(NSError *error)
        {
            if (error)
            {
                // TODO
            }
            else
            {
                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds))
                                        animated:NO];
            }
        }];
    }
}

- (void)loadNextPageAction
{
    [self.tableDataSource loadNextPageWithCompletion:nil];
}

#pragma mark - VMessageTableDataDelegate methods

- (UITableViewCell *)dataSource:(VMessageTableDataSource *)dataSource cellForMessage:(VMessage *)message atIndexPath:(NSIndexPath *)indexPath
{
    VMessageCell *cell = [dataSource.tableView dequeueReusableCellWithIdentifier:kVMessageCellNibName forIndexPath:indexPath];
    
    cell.timeLabel.text = [message.postedAt timeSince];
    cell.commentTextView.text = message.text;
    
    if ([message.user isEqualToUser:[[VObjectManager sharedManager] mainUser]])
    {
        cell.profileImageOnRight = YES;
    }
    
    BOOL hasMedia = [message.thumbnailPath isKindOfClass:[NSString class]] && ![message.thumbnailPath isEqualToString:@""];
    if (hasMedia)
    {
        cell.commentTextView.hasMedia = YES;
        cell.commentTextView.mediaThumbnailView.hidden = NO;
        [cell.commentTextView.mediaThumbnailView setImageWithURL:[NSURL URLWithString:message.thumbnailPath]];
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
    
    NSURL *pictureURL = [NSURL URLWithString:message.user.profileImagePathSmall ?: message.user.pictureUrl];
    if (pictureURL)
    {
        [cell.profileImageView setImageWithURL:pictureURL];
    }
    cell.onProfileImageTapped = ^(void)
    {
        VUserProfileViewController* profileViewController = [VUserProfileViewController userProfileWithUser:message.user];
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
    if (scrollView.contentOffset.y < CGRectGetHeight(scrollView.bounds) * 0.5f &&
        ![self.tableDataSource isLoading] &&
        [self.tableDataSource areMorePagesAvailable])
    {
        [self loadNextPageAction];
    }
}

@end
