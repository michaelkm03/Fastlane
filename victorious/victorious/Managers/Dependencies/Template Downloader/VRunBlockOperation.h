//
//  VRunBlockOperation.h
//  victorious
//
//  Created by Josh Hinman on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 An NSOperation subclass that runs a block on a specific queue.
 */
@interface VRunBlockOperation : NSOperation

@property (nonatomic, copy) void (^block)(); ///< This block will be executed in this operation's -main method
@property (nonatomic, strong) dispatch_queue_t queue; ///< If set, the block will be submitted to this queue synchronously. If nil, the block will execute on whatever queue or thread this operation's -main method runs on.

@end
