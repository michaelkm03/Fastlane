//
//  VTimerManager.h
//  victorious
//
//  Created by Sharif Ahmed on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/*
 GOAL: get rid of timer-related crashes caused by timer calling on objects that would otherwise be deallocated
 
 HOW: create an object that we could interact with much like a timer but would have a weak reference to the target. The weak reference to the target allows the target to be deallocated whenever needed and allows us to ensure the target exists before calling the function on it.
 
 CONCERNS:
    - Threading: if timers must be removed from the same thread that they were created on. If we're creating this manager from various threads, we need to make sure it's calling invalidate on timers from the proper threads to remove it from the run loop. (NOTE: not an issue, the timer fires on the same thread that it was created on, so as long as we don't jump onto the main thread, we're good to invalidate it)
    - Retain cycles: make damn sure this manager doesn't retain the target unnecessarily as it would defeat the whole purpose.
    - Support for all needed timer methods: find which ones are currently used and build for those, allow expansion on this class later.
 
 TESTING:
    - Thread safety (no need to test since we're just invalidating on the thread that the timer fires on)
    - Proper weak reference to target
 */

#import <Foundation/Foundation.h>

@interface VTimerManager : NSObject

/**

 */
+ (VTimerManager *)scheduledTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                                  target:(id)aTarget
                                                selector:(SEL)aSelector
                                                userInfo:(id)userInfo
                                                 repeats:(BOOL)yesOrNo;
/**
 
 */
+ (VTimerManager *)addTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                            target:(id)aTarget
                                          selector:(SEL)aSelector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)yesOrNo
                                         toRunLoop:(NSRunLoop *)runLoop
                                       withRunMode:(NSString *)runMode;
- (void)invalidate;

@end
