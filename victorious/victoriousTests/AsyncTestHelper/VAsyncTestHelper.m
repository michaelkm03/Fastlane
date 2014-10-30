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
    [self waitForSignalUntil:waitUntil withSignalBlock:nil];
}

- (BOOL)waitForSignalWithoutThrowing:(NSTimeInterval)waitTime
{
    NSDate *waitUntil = [NSDate dateWithTimeIntervalSinceNow:waitTime];
    return [self waitForSignalUntil:waitUntil withSignalBlock:nil throws:NO];
}

- (void)waitForSignalUntil:(NSDate *)waitUntil
{
    [self waitForSignalUntil:waitUntil withSignalBlock:nil];
}

- (void)waitForSignal:(NSTimeInterval)waitTime withSignalBlock:(BOOL(^)())signalBlock
{
    NSDate *waitUntil = [NSDate dateWithTimeIntervalSinceNow:waitTime];
    [self waitForSignalUntil:waitUntil withSignalBlock:signalBlock];
}

- (void)waitForSignalUntil:(NSDate *)waitUntil withSignalBlock:(BOOL (^)())signalBlock
{
    [self waitForSignalUntil:waitUntil withSignalBlock:signalBlock throws:YES];
}

- (BOOL)waitForSignalUntil:(NSDate *)waitUntil withSignalBlock:(BOOL(^)())signalBlock throws:(BOOL)shouldThrow
{
    NSAssert(!shouldThrow || [NSThread isMainThread], @"shouldThrow should only be YES on the main thread");
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW))
    {
        if ( signalBlock != nil && signalBlock() )
        {
            [self signal];
        }
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        if ([waitUntil timeIntervalSinceNow] <= 0)
        {
            if (shouldThrow)
            {
                [NSException raise:NSInternalInconsistencyException format:@"Asynchronous block never signaled"];
            }
            else
            {
                return NO;
            }
        }
    }
    return YES;
}

@end
