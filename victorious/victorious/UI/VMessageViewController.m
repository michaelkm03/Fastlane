//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageViewController.h"
#import "VObjectManager+DirectMessaging.h"
#import "VCommentCell.h"
#import "VMessage+RestKit.h"
#import "VMedia+RestKit.h"
#import "VKeyboardBarViewController.h"
#import "VThemeManager.h"
#import "VObjectManager.h"
#import "VUser+RestKit.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

@interface VMessageViewController ()
@property (nonatomic, readwrite, strong)    NSArray*    messages;
@end

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    [backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.conversation.user.pictureUrl]
                               placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                      tintColor:[UIColor darkGrayColor]];
    
    self.tableView.backgroundView = backgroundImageView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    [self.tableView registerNib:[UINib nibWithNibName:kMessageCellIdentifier bundle:nil]
         forCellReuseIdentifier:kMessageCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherCommentCellIdentifier bundle:nil]
         forCellReuseIdentifier:kOtherCommentCellIdentifier];
    
    [self.tableView reloadData];
    [self refresh];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

- (void)refresh
{
    __block NSInteger oldMessageCount = [self.messages count];
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error.localizedDescription);
        
        [self delayedRefresh];
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
        self.messages = [[self.conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
        [self.tableView reloadData];
        
        if (oldMessageCount != [self.messages count]
            && self.tableView.contentSize.height > self.tableView.frame.size.height)
        {
            CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            [self.tableView setContentOffset:offset animated:YES];
        }
    
        [[VObjectManager sharedManager] markConversationAsRead:self.conversation
                                                  successBlock:nil
                                                     failBlock:fail];
        [self delayedRefresh];
    };
    
    [[VObjectManager sharedManager] loadNextPageOfMessagesForConversation:self.conversation
                                                             successBlock:success
                                                                failBlock:fail];
}

- (void)delayedRefresh
{
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if(self.isViewLoaded && self.view.window)
                       {
                           [self refresh];
                       }
                   });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    VMessage*   aMessage = self.messages[indexPath.row];
    if([aMessage.user isEqualToUser:[VObjectManager sharedManager].mainUser])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kOtherCommentCellIdentifier forIndexPath:indexPath];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellIdentifier forIndexPath:indexPath];
    }
    
    [(VCommentCell *)cell setCommentOrMessage:aMessage];
    
    [cell setNeedsDisplay];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage*   aMessage = self.messages[indexPath.row];

    CGFloat height = [VCommentCell frameSizeForMessageText:aMessage.text].height;
    CGFloat yOffset = [aMessage.media.mediaUrl length] ? kMediaCommentCellYOffset : kCommentCellYOffset;
    height = MAX(height + yOffset, kMinCellHeight);
    
    return height;
}

@end
