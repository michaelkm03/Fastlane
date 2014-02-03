//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamsSubViewController.h"
#import "VCommentsTableViewController.h"
#import "VKeyboardBarViewController.h"
#import "VSequence.h"
#import "VUser.h"

@interface VStreamsSubViewController()
<VCommentsTableViewControllerDelegate>
@end

@implementation VStreamsSubViewController

@synthesize conversationTableViewController = _conversationTableViewController;

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
    {
        VCommentsTableViewController *streamsCommentsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        streamsCommentsController.delegate = self;
        streamsCommentsController.sequence = self.sequence;
        streamsCommentsController.composeViewController = self.composeViewController;
        [self addChildViewController:streamsCommentsController];
        [streamsCommentsController didMoveToParentViewController:self];
        _conversationTableViewController = streamsCommentsController;
    }

    return _conversationTableViewController;
}

#pragma mark - VCommentsTableViewControllerDelegate

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user
{
    self.composeViewController.textField.text = [NSString stringWithFormat:@"@%@ ", user.name];
    [self.composeViewController.textField becomeFirstResponder];
}

@end
