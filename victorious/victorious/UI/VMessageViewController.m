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
#import "UIImageView+Blurring.h"
#import "VCommentTextAndMediaView.h"
#import "VConstants.h"
#import "VKeyboardBarViewController.h"
#import "VMessageViewController.h"
#import "VMessageCell.h"
#import "VMessage+RestKit.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"
#import "VObjectManager.h"
#import "VPaginationManager.h"
#import "VThemeManager.h"
#import "VUser+RestKit.h"
#import "VUserProfileViewController.h"

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage*    defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyLightEffect];
    
    [backgroundImageView setLightBlurredImageWithURL:[NSURL URLWithString:self.conversation.user.pictureUrl]
                                    placeholderImage:defaultBackgroundImage];
    
    self.tableView.backgroundView = backgroundImageView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    
    [self refreshFetchController];
}

#pragma mark - fetched results controller

- (NSFetchedResultsController *)makeFetchedResultsController
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VMessage entityName]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
    
    NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"conversation.remoteId = %@", self.conversation.remoteId];
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:20]; //[self currentFilter].perPageNumber.integerValue];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext
                                                 sectionNameKeyPath:nil
                                                          cacheName:fetchRequest.entityName];
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender
{
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error.localizedDescription);
        [self.refreshControl endRefreshing];
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self.refreshControl endRefreshing];
    };
    
    [[VObjectManager sharedManager] loadNextPageOfConversation:self.conversation
                                                  successBlock:success
                                                     failBlock:fail];
}

- (void)loadNextPageAction
{
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"Failed to load next page: %@", error.localizedDescription);
        [self.refreshControl endRefreshing];
    };
    
    NSInteger preRefreshCount = self.fetchedResultsController.fetchedObjects.count;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [self.refreshControl endRefreshing];
        
        if (preRefreshCount < self.fetchedResultsController.fetchedObjects.count &&
            self.tableView.contentSize.height > self.tableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(self.tableView.contentOffset.x,
                                         self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:YES];
        }
        
        [[VObjectManager sharedManager] markConversationAsRead:self.conversation
                                                  successBlock:nil
                                                     failBlock:fail];
    };
    
    [[VObjectManager sharedManager] refreshMessagesForConversation:self.conversation
                                                      successBlock:success
                                                         failBlock:fail];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kVMessageCellNibName forIndexPath:indexPath];
    VMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

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
    
    NSURL *pictureURL = [NSURL URLWithString:message.user.pictureUrl];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL hasMedia = [message.thumbnailPath isKindOfClass:[NSString class]] && ![message.thumbnailPath isEqualToString:@""];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) text:message.text withMedia:hasMedia];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kVMessageCellNibName bundle:nil]
         forCellReuseIdentifier:kVMessageCellNibName];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.conversation.currentPageNumber.intValue < self.conversation.maxPageNumber.intValue &&
        [[self.fetchedResultsController sections][0] numberOfObjects] &&
        ![[[VObjectManager sharedManager] paginationManager] isLoadingFilter:self.conversation] &&
        scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height * .75)
    {
        [self loadNextPageAction];
    }
    
    //Notify the container about the scroll so it can handle the header
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

@end
