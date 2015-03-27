//
//  VSequenceActionsSender.h
//  victorious
//
//  Created by Josh Hinman on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VSequenceActionsDelegate;

/**
 Objects conforming to this protocol initiate sequence actions by sending messages to a sequence actions delegate.
 */
@protocol VSequenceActionsSender <NSObject>

@required

/**
 Sets an object that will receive sequence actions from this sender.
 */
- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)delegate;

@end
