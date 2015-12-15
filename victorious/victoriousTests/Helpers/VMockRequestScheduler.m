//
//  VMockRequestScheduler.m
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VMockRequestScheduler.h"

@implementation VMockRequestScheduler

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _requestsScheduled = [[NSMutableArray alloc] init];
        _requestsSent = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)scheduleRequest:(NSURLRequest *)request
{
    [self.requestsScheduled addObject:request];
}

- (void)sendSingleRequest:(NSURLRequest *)request
{
    [self.requestsSent addObject:request];
}

@end
