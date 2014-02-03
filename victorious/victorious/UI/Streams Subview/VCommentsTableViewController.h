//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSequence.h"

@class VKeyboardBarViewController;

@protocol VCommentsTableViewControllerDelegate;

@interface VCommentsTableViewController : UITableViewController
@property (nonatomic, strong) VSequence* sequence;
@property (nonatomic, weak) VKeyboardBarViewController* composeViewController;
@property (nonatomic, weak) id<VCommentsTableViewControllerDelegate> delegate;

+ (instancetype)sharedInstance;
@end

@protocol VCommentsTableViewControllerDelegate <NSObject>

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user;

@end