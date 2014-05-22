//
//  VMessageSubViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"
#import "VObjectManager.h"
#import "VObjectManager+DirectMessaging.h"
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
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    VMessageViewController* messageVC = (VMessageViewController*)self.conversationTableViewController;
    
    self.navigationItem.title = messageVC.conversation.user.name ? [@"@" stringByAppendingString:messageVC.conversation.user.name] : @"Message";
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UITableViewController *)conversationTableViewController
{
    if (_conversationTableViewController == nil)
    {
        VMessageViewController *messageController = [self.storyboard instantiateViewControllerWithIdentifier:@"messages"];
        messageController.conversation = self.conversation;
        _conversationTableViewController = messageController;
    }
    
    return _conversationTableViewController;
}

- (void)keyboardBar:(VKeyboardBarViewController *)keyboardBar didComposeWithText:(NSString *)text mediaURL:(NSURL *)mediaURL
{
    
    __block NSURL* urlToRemove = mediaURL;
    
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        [[NSFileManager defaultManager] removeItemAtURL:urlToRemove error:nil];
        
        NSDictionary* payload = fullResponse[@"payload"];
        
        if (!self.conversation.remoteId)
        {
            self.conversation.remoteId = payload[@"conversation_id"];
            [self.conversation.managedObjectContext saveToPersistentStore:nil];
        }
        
        [(VMessageViewController *)self.conversationTableViewController refresh];
        
        VLog(@"Succeed with response: %@", fullResponse);
    };
    
    [[VObjectManager sharedManager] sendMessageToUser:self.conversation.user
                                             withText:text
                                             mediaURL:mediaURL
                                         successBlock:success
                                            failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed in creating message with error: %@", error);
        [[NSFileManager defaultManager] removeItemAtURL:urlToRemove error:nil];
     }];
}

@end
