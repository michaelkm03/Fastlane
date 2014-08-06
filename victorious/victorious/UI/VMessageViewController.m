//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+VParseHelp.h"
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
#import "VThemeManager.h"
#import "VUser+RestKit.h"

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

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
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VMessage entityName]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
    
    NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"conversation.remoteId = %@", self.conversation.remoteId];
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:20]; //[self currentFilter].perPageNumber.integerValue];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:context
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

- (void)delayedRefresh
{
    return; // TODO
    
    double delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if (self.isViewLoaded && self.view.window)
                       {
                           [self loadNextPageAction];
                       }
                   });
}

- (void)loadNextPageAction
{
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"Failed to load next page: %@", error.localizedDescription);
        [self.refreshControl endRefreshing];
        
        [self delayedRefresh];
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
        [self delayedRefresh];
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

    cell.commentTextView.text = message.text;
    NSURL *pictureURL = [NSURL URLWithString:message.user.pictureUrl];
    if (pictureURL)
    {
        [cell.profileImageButton setImageWithURL:pictureURL placeholderImage:nil forState:UIControlStateNormal];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) text:message.text];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [VMessageCell estimatedHeightWithWidth:CGRectGetWidth(tableView.bounds) text:@"Lorem ipsum dolor sit amet"];
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kVMessageCellNibName bundle:nil]
         forCellReuseIdentifier:kVMessageCellNibName];
}

@end
