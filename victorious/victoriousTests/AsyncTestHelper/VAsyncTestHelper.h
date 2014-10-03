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
 will not return until -signal is called.
 When the "waitUntil" date arrives, an exception is thrown.
 */
- (void)waitForSignalUntil:(NSDate *)waitUntil;

@end
