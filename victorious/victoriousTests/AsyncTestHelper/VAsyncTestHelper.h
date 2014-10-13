//
//  VAsyncTestHelper.h
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class can be used to synchronize
 an asynchronous method call.
 */
@interface VAsyncTestHelper : NSObject

/**
 Call this method from within the completion
 block passed to the async function you are
 testing. It is safe to call this method
 from any thread.
 */
- (void)signal;

/**
 Call this method just before your assertions. It
 will not return until -signal is called.
 */
- (void)waitForSignal;

/**
 Call this method just before your assertions. It
 will return when -signal is called.
 If "waitTime" expires, an exception is thrown.
 */
- (void)waitForSignal:(NSTimeInterval)waitTime;

/**
 Call this method just before your assertions. It
 will return when -signal is called, or "waitTime"
 expires, whichever comes first.
 
 @return YES if -signal was called, or NO if waitTime
         elapsed without a signal.
 */
- (BOOL)waitForSignalWithoutThrowing:(NSTimeInterval)waitTime;

/**
 Call this method just before your assertions. It
 will not return until -signal is called.
 When the "waitUntil" date arrives, an exception is thrown.
 */
- (void)waitForSignalUntil:(NSDate *)waitUntil;

/**
 Call this method just before your assertions. It
 will not return until -signal is called or signalBlock returns YES.
 If "waitTime" expires, an exception is thrown.
 */
- (void)waitForSignal:(NSTimeInterval)waitTime withSignalBlock:(BOOL(^)())signalBlock;

/**
 Call this method just before your assertions. It
 will not return until -signal is called or signalBlock returns YES.
 When the "waitUntil" date arrives, an exception is thrown.
 */
- (void)waitForSignalUntil:(NSDate *)waitUntil withSignalBlock:(BOOL(^)())signalBlock;

/**
 Call this method just before your assertions. It
 will not return until -signal is called or signalBlock returns YES.
 When the "waitUntil" date arrives, if "shouldThrow" is YES, an exception is thrown,
 otherwise the method returns.
 
 @return YES if -signal was called, or NO if waitUntil
         was reached without a signal.
 */
- (BOOL)waitForSignalUntil:(NSDate *)waitUntil withSignalBlock:(BOOL(^)())signalBlock throws:(BOOL)shouldThrow;

@end
