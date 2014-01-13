//
//  VConversationSubViewController.h
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VComposeViewController;

@interface VConversationSubViewController : UIViewController

@property (weak, nonatomic) VComposeViewController *composeViewController;
@property (strong, nonatomic) UITableViewController *conversationTableViewController;

@end
