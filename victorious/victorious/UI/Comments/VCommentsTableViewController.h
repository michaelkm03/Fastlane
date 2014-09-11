//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

@class VSequence, VUser, VComment;

@protocol VCommentsTableViewControllerDelegate;

#import "VKeyboardBarViewController.h"

@interface VCommentsTableViewController : UITableViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) id<VCommentsTableViewControllerDelegate> delegate;

- (void)addedNewComment:(VComment *)comment;

@end

@protocol VCommentsTableViewControllerDelegate <NSObject>

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user;

@end