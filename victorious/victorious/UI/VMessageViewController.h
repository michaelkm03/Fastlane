//
//  VMessageViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VConversation;
@class VComposeViewController;

@interface VMessageViewController : UITableViewController
@property (nonatomic, readwrite, strong)    VConversation*  conversation;
@property (nonatomic, weak) VComposeViewController* composeViewController;
@end
