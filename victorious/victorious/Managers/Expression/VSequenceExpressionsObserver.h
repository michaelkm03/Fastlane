//
//  VExpressionController.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

/**
 A simple wrapper for KVO on sequences likes and comment counts, but open for
 expansion of any other sequences data that must be kept up to date in stream
 or content views while the user is interacting with it.  All cleanup is handled
 internally, so calling code may create this object freely and call any of its
 methods as many times as it wants.
 */
@interface VSequenceExpressionsObserver : NSObject

/**
 Starts observing likes and comments on the sequence and calls the update block
 whenever any property changes and the UI should be updated.
 */
- (void)startObservingWithSequence:(VSequence *)sequence onUpdate:(void(^)())update;

/**
 Stops observering.  This is here for convenience, but all cleanup is handled
 internally and calling code need never call this directly.
 */
- (void)stopObserving;

@end
