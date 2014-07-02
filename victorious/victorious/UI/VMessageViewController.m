//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageViewController.h"

#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Pagination.h"

#import "VMessageCell.h"
#import "VMessage+RestKit.h"
#import "VKeyboardBarViewController.h"
#import "VThemeManager.h"
#import "VObjectManager.h"
#import "VUser+RestKit.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"
#import "NSString+VParseHelp.h"
#import "VConstants.h"

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage*    defaultBackgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice] applyLightEffect];
    
    [backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.conversation.user.pictureUrl]
                                    placeholderImage:defaultBackgroundImage
                                           tintColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    
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
    return;
    
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
        NSLog(@"%@", error.localizedDescription);
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
    UITableViewCell *cell = nil;
    VMessage*   aMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([aMessage.user isEqualToUser:[VObjectManager sharedManager].mainUser])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kOtherMessageCellIdentifier forIndexPath:indexPath];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
    }
    
    [(VMessageCell *)cell setMessage:aMessage];
    [(VMessageCell *)cell setParentTableViewController:self];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setNeedsDisplay];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage*   aMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];

    CGFloat height = [VMessageCell frameSizeForMessageText:aMessage.text].height;
    CGFloat yOffset = aMessage.thumbnailPath && ![aMessage.thumbnailPath isEmpty] ? kMessageMediaCellYOffset : kMessageCellYOffset;
    height = MAX(height + yOffset, kMessageMinCellHeight);
    
    return height;
}

- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kMessageCellIdentifier bundle:nil]
         forCellReuseIdentifier:kMessageCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherMessageCellIdentifier bundle:nil]
         forCellReuseIdentifier:kOtherMessageCellIdentifier];
}

@end
