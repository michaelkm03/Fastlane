//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"
#import "VConversation.h"
#import "VUser.h"
#import "NSString+VParseHelp.h"

@interface VMessageContainerViewController ()
@end

@implementation VMessageContainerViewController
@synthesize conversationTableViewController = _conversationTableViewController;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    VMessageViewController* messageVC = (VMessageViewController*)self.conversationTableViewController;
    self.navigationItem.title = [@"@" stringByAppendingString:messageVC.conversation.user.name];
}

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
