//
//  VTimerManager.h
//  victorious
//
//  Created by Sharif Ahmed on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTimerManager : NSObject

/**
 Equivalent to NSTimer's scheduleTimerWithTimeInterval:target:selector:userInfo:repeats: function but with a weak reference to the target instead of strong reference.
 
 @param timeInterval The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 @param aTarget The object to which to send the message specified by aSelector when the timer fires. The timer manager maintains a weak reference to target.
 @param aSelector The message to send to target when the internal timer fires. The selector should have one of the following signatures: timerFired, timerFired: . All other signatures are invalid and will cause an assertion failure.
 @param Custom user info for the internal timer. The internal timer maintains a strong reference to this object until the internal timer is invalidated (which occurs after the provided selector is called on the provided target). This parameter may be nil.
 @param repeats If YES, the internal timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 
 @return A new timerManager instance containing a scheduled NSTimer and a weak reference to the supplied target.
 */
+ (VTimerManager *)scheduledTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                                  target:(id)aTarget
                                                selector:(SEL)aSelector
                                                userInfo:(id)userInfo
                                                 repeats:(BOOL)repeats;
/**
 Equivalent to NSTimer's scheduleTimerWithTimeInterval:target:selector:userInfo:repeats: function but with a weak reference to the target instead of strong reference.
 
 @param timeInterval The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 @param aTarget The object to which to send the message specified by aSelector when the timer fires. The timer manager maintains a weak reference to target.
 @param aSelector The message to send to target when the internal timer fires. The selector should have one of the following signatures: timerFired, timerFired: . All other signatures are invalid and will cause an assertion failure.
 @param Custom user info for the internal timer. The internal timer maintains a strong reference to this object until the internal timer is invalidated (which occurs after the provided selector is called on the provided target). This parameter may be nil.
 @param repeats If YES, the internal timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 @param runLoop The runLoop that should have the timer added to it
 @param runMode The runMode The mode in which to add aTimer. You may specify a custom mode or use one of the modes listed in Run Loop Modes.
 
 @return A new timerManager instance containing an NSTimer that has been added to the provided runLoop in the provided runMode and a weak reference to the supplied target.
 */
+ (VTimerManager *)addTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                            target:(id)aTarget
                                          selector:(SEL)aSelector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)repeats
                                         toRunLoop:(NSRunLoop *)runLoop
                                       withRunMode:(NSString *)runMode;
/**
 Stops the receiver from ever firing again and requests its removal from its run loop. This function always calls invalidate on the thread that created the timer, which allows it to be properly removed from the run loop.
 */
- (void)invalidate;

/**
 Equivalent to calling -isValid on an NSTimer, indicates if the timer is valid or not
 */
- (BOOL)isValid;

@end
