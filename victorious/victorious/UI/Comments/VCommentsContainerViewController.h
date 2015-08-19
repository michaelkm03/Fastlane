//
//  VStreamsSubViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VDependencyManager.h"

@class VSequence, VComment, VDependencyManager;

@interface VCommentsContainerViewController : VKeyboardBarContainerViewController

@property (nonatomic, readonly) VSequence *sequence;

@end

#pragma mark -

@interface VDependencyManager (VCommentsContainerViewController)

- (VCommentsContainerViewController *)commentsContainerWithSequence:(VSequence *)sequence;

- (VCommentsContainerViewController *)commentsContainerWithSequence:(VSequence *)sequence andSelectedComment:(VComment *)selectedComment;

@end