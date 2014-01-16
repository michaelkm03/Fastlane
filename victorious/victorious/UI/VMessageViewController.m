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
#import "VComposeViewController.h"
#import "VThemeManager.h"
#import "VObjectManager.h"
#import "VUser+RestKit.h"

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

@interface VMessageViewController () <VComposeMessageDelegate>
@property (nonatomic, readwrite, strong)    NSArray*    messages;
@end

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.composeViewController.delegate = self;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    [self.tableView registerNib:[UINib nibWithNibName:kCommentCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherCommentCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kOtherCommentCellIdentifier];

    [self loadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

 - (void)loadData
{
    [[[VObjectManager sharedManager] loadNextPageOfMessagesForConversation:self.conversation
                                                              successBlock:^(NSArray *resultObjects)
      {
          [[[VObjectManager sharedManager] markConversationAsRead:self.conversation successBlock:^(NSArray *resultObjects)
            {
                NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
                self.messages = [[self.conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
                [self.tableView reloadData];
            }
            failBlock:^(NSError *error)
            {
                NSLog(@"%@", error.localizedDescription);
            }] start];
          
      }
      failBlock:^(NSError *error)
      {
          NSLog(@"%@", error.localizedDescription);
      }] start];
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
//    if([aMessage.user isEqualToUser:[VObjectManager sharedManager].mainUser])
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:kOtherCommentCellIdentifier forIndexPath:indexPath];
//    }else
//    {
        cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier forIndexPath:indexPath];
//    }

    [(VCommentCell *)cell setCommentOrMessage:aMessage];

    return cell;
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VMessage*   aMessage = self.messages[indexPath.row];
    if (aMessage.media.mediaUrl)
        return kMessageRowWithMediaHeight;
    else
        return kMessageRowHeight;
}

#pragma mark - VComposeMessageDelegate

- (void)didComposeWithText:(NSString *)text data:(NSData *)data mediaExtension:(NSString *)mediaExtension mediaURL:(NSURL *)mediaURL
{
    [[VObjectManager sharedManager] sendMessageToUser:self.conversation.user
                                              withText:text
                                                  Data:data
                                        mediaExtension:mediaExtension
                                             mediaUrl:nil
                                          successBlock:^(AFHTTPRequestOperation* operation, id response)
                                          {
                                              if (!self.conversation.remoteId)
                                              {
                                                  self.conversation.remoteId = response[@"payload"][@"conversation_id"];
                                                  [self.conversation.managedObjectContext save:nil];
                                              }
                                              [self loadData];
                                               VLog(@"Succeed with response: %@", response);
                                          }
                                             failBlock:^(AFHTTPRequestOperation* operation, NSError *error)
                                          {
                                               VLog(@"Failed in creating message with error: %@", error);
                                        }];
}

@end
