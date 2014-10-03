//
//  VAsyncTestHelper.m
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsyncTestHelper.h"

@interface VAsyncTestHelper ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation VAsyncTestHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)signal
{
    dispatch_semaphore_signal(self.semaphore);
}

- (void)waitForSignal
{
    [self waitForSignalUntil:[NSDate distantFuture]];
}

- (void)waitForSignal:(NSTimeInterval)waitTime
{
    NSDate *waitUntil = [NSDate dateWithTimeIntervalSinceNow:waitTime];
    [self waitForSignalUntil:waitUntil];
}

- (void)waitForSignalUntil:(NSDate *)waitUntil
{
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        if ([waitUntil timeIntervalSinceNow] <= 0)
        {
            [NSException raise:NSInternalInconsistencyException format:@"Asynchronous block never signaled"];
        }
    }
}

@end
