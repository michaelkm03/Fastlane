//
//  VStreamsSubViewController.h
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VHasManagedDependencies.h"

@class VSequence, VUser, VComment;

@protocol VCommentsTableViewControllerDelegate;

@interface VCommentsTableViewController : UITableViewController <VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, weak) id<VCommentsTableViewControllerDelegate> delegate;

/**
 Creates a new instance of VCommentsTableViewController by passing in an instance of VDependencyManager
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)addedNewComment:(VComment *)comment;

@end

@protocol VCommentsTableViewControllerDelegate <NSObject>

- (void)streamsCommentsController:(VCommentsTableViewController *)viewController shouldReplyToUser:(VUser *)user;

@end