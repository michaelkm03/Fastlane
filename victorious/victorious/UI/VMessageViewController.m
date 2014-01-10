//
//  VMessageViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageViewController.h"
#import "VObjectManager+DirectMessaging.h"

@interface VMessageViewController ()
@property (nonatomic, readwrite, strong)    NSArray*    messages;
@end

@implementation VMessageViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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

        }] start];
        
    }
                                                       failBlock:^(NSError *error)
    {
     
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    VMessage*   aMessage = self.messages[indexPath.row];
    
    return cell;
}

@end
