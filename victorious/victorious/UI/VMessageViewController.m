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

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

@interface VMessageViewController () <VKeyboardBarDelegate>
@property (nonatomic, readwrite, strong)    NSArray*    messages;
@end

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.composeViewController.delegate = self;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKeyPath:@"theme.color.messages.background"];
    [self.tableView registerNib:[UINib nibWithNibName:kCommentCellIdentifier bundle:nil]
         forCellReuseIdentifier:kCommentCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kOtherCommentCellIdentifier bundle:nil]
         forCellReuseIdentifier:kOtherCommentCellIdentifier];

    [self refreshAction:self];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

 - (IBAction)refreshAction:(id)sender
{
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        NSLog(@"%@", error.localizedDescription);
    };
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
        self.messages = [[self.conversation.messages allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
        [self.tableView reloadData];
        
        [[VObjectManager sharedManager] markConversationAsRead:self.conversation
                                                  successBlock:nil
                                                     failBlock:fail];
    };
    
    //TODO: get rid of this once message pagination works
    //If we have more than 1 message we've already loaded at least 1 page
    if ([self.conversation.messages count] > 1)
    {
        success (nil, nil, nil);
        return;
    }
    
    [[VObjectManager sharedManager] loadNextPageOfMessagesForConversation:self.conversation
                                                             successBlock:success                                                                failBlock:fail];
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
                                         successBlock:^(NSOperation* operation, id fullResponse, NSArray* rkObjects)
                                        {
                                              NSDictionary* payload = fullResponse[@"payload"];
                                              if (!self.conversation.remoteId)
                                              {
                                                  self.conversation.remoteId = payload[@"conversation_id"];
                                                  [self.conversation.managedObjectContext save:nil];
                                              }
                                              
                                              [self refreshAction:self];
                                              
                                               VLog(@"Succeed with response: %@", fullResponse);
                                        }
                                            failBlock:^(NSOperation* operation, NSError* error)
                                          {
                                               VLog(@"Failed in creating message with error: %@", error);
                                          }];
}

@end
