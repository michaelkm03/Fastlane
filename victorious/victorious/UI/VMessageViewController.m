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

const   CGFloat     kMessageRowWithMediaHeight  =   280.0;
const   CGFloat     kMessageRowHeight           =   80;

@interface VMessageViewController ()
@property (nonatomic, readwrite, strong)    NSArray*    messages;
@end

@implementation VMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:kCommentCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kCommentCellIdentifier];

    [[[VObjectManager sharedManager] loadNextPageOfConversations:^(NSArray *resultObjects)
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier forIndexPath:indexPath];
    
    VMessage*   aMessage = self.messages[indexPath.row];
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

@end
