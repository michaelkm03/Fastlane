//
//  VRunBlockOperation.m
//  victorious
//
//  Created by Josh Hinman on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VRunBlockOperation.h"

@implementation VRunBlockOperation

- (void)main
{
    NSParameterAssert( self.block != nil );
    
    dispatch_queue_t queue = self.queue;
    if ( queue != nil )
    {
        dispatch_sync(queue, self.block);
    }
    else
    {
        self.block();
    }
}

@end
