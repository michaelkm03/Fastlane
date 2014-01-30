//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSequence.h"

@class VKeyboardBarViewController;

@protocol VStreamsCommentsControllerDelegate;

@interface VStreamsCommentsController : UITableViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) VKeyboardBarViewController* composeViewController;
@property (nonatomic, weak) id<VStreamsCommentsControllerDelegate> delegate;
@end

@protocol VStreamsCommentsControllerDelegate <NSObject>

- (void)streamsCommentsController:(VStreamsCommentsController *)viewController shouldReplyToUser:(VUser *)user;

@end