//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentsContainerViewController.h"
#import "VCommentsTableViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence.h"
#import "VUser.h"
#import "VConstants.h"
#import "VObjectManager+Comment.h"

@interface VCommentsContainerViewController() <VCommentsTableViewControllerDelegate>
@end

@implementation VCommentsContainerViewController

@synthesize conversationTableViewController = _conversationTableViewController;

+ (instancetype)commentsContainerView
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VCommentsContainerViewController* commentsContainerViewController = (VCommentsContainerViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kCommentsContainerStoryboardID];

    return commentsContainerViewController;
}

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
    {
        VCommentsTableViewController *streamsCommentsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        streamsCommentsController.delegate = self;
        streamsCommentsController.sequence = self.sequence;
//        streamsCommentsController.keyboardBarViewController = self.keyboardBarViewController;
        self.keyboardBarViewController.delegate = streamsCommentsController;
        [self addChildViewController:streamsCommentsController];
        [streamsCommentsController didMoveToParentViewController:self];
        _conversationTableViewController = streamsCommentsController;
    }

    return _conversationTableViewController;
}

#pragma mark - VCommentsTableViewControllerDelegate

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user
{
    self.keyboardBarViewController.textField.text = [NSString stringWithFormat:@"@%@ ", user.name];
    [self.keyboardBarViewController.textField becomeFirstResponder];
}

@end
