//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"

@interface VMessageContainerViewController ()
@end

@implementation VMessageContainerViewController
@synthesize conversationTableViewController = _conversationTableViewController;

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
    {
        VMessageViewController *messageController = [self.storyboard instantiateViewControllerWithIdentifier:@"messages"];
        messageController.conversation = self.conversation;
        messageController.composeViewController = self.keyboardBarViewController;
        [self addChildViewController:messageController];
        [messageController didMoveToParentViewController:self];
        _conversationTableViewController = messageController;
    }
    
    return _conversationTableViewController;
}

@end
