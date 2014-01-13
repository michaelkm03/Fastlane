//
//  VStreamsSubViewController.m
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamsSubViewController.h"
#import "VStreamsCommentsController.h"
#import "VSequence.h"

@implementation VStreamsSubViewController

@synthesize conversationTableViewController = _conversationTableViewController;

- (UITableViewController *)conversationTableViewController
{
    if(_conversationTableViewController == nil)
    {
        VStreamsCommentsController *streamsCommentsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"comments"];
        streamsCommentsController.sequence = self.sequence;
        streamsCommentsController.composeViewController = self.composeViewController;
        [self addChildViewController:streamsCommentsController];
        [streamsCommentsController didMoveToParentViewController:self];
        _conversationTableViewController = streamsCommentsController;
    }

    return _conversationTableViewController;
}

@end
