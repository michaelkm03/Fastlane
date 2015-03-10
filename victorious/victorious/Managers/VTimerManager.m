//
//  VTimerManager.m
//  victorious
//
//  Created by Sharif Ahmed on 3/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTimerManager.h"

static const NSUInteger VMaxArgs = 3; //3 is the 1 maximum parameter + the selector and object that must be passed in every call

@interface VTimerManager ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) BOOL expectsTimer;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, strong) NSThread *timerThread;

@end

@implementation VTimerManager

+ (VTimerManager *)scheduledTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                                  target:(id)aTarget
                                                selector:(SEL)aSelector
                                                userInfo:(id)userInfo
                                                 repeats:(BOOL)repeats
{
    NSAssert(aTarget != nil, @"Target must not be nil");
    NSAssert(aSelector != nil, @"Selector must not be nil");
    
    NSMethodSignature *sig = [aTarget methodSignatureForSelector:aSelector];
    NSAssert(sig != nil, @"Target must have signature for selector");
    
    NSUInteger numberOfArgs = [sig numberOfArguments];
    NSAssert(numberOfArgs <= VMaxArgs, @"Selector must only expect 1 or fewer arguments");
    
    VTimerManager *timerManager = [[VTimerManager alloc] init];
    timerManager.target = aTarget;
    timerManager.selector = aSelector;
    timerManager.expectsTimer = numberOfArgs == VMaxArgs;
    timerManager.repeats = repeats;
    timerManager.timerThread = [NSThread currentThread];
    timerManager.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:timerManager selector:@selector(timerFired:) userInfo:userInfo repeats:repeats];
    return timerManager;
    
}

+ (VTimerManager *)addTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                            target:(id)aTarget
                                          selector:(SEL)aSelector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)repeats
                                         toRunLoop:(NSRunLoop *)runLoop
                                       withRunMode:(NSString *)runMode
{
    NSAssert(aTarget != nil, @"Target must not be nil");
    NSAssert(aSelector != nil, @"Selector must not be nil");
    NSAssert(runLoop != nil, @"RunLoop must not be nil");
    
    NSMethodSignature *sig = [aTarget methodSignatureForSelector:aSelector];
    NSAssert(sig != nil, @"Target must have signature for selector");
    
    NSUInteger numberOfArgs = [sig numberOfArguments];
    NSAssert(numberOfArgs <= VMaxArgs, @"Selector must only expect 1 or fewer arguments");
    
    VTimerManager *timerManager = [[VTimerManager alloc] init];
    timerManager.target = aTarget;
    timerManager.selector = aSelector;
    timerManager.expectsTimer = numberOfArgs == VMaxArgs;
    timerManager.repeats = repeats;
    timerManager.timerThread = [NSThread currentThread];
    timerManager.timer = [NSTimer timerWithTimeInterval:timeInterval target:timerManager selector:@selector(timerFired:) userInfo:userInfo repeats:repeats];
    [runLoop addTimer:timerManager.timer forMode:runMode];
    return timerManager;
    
}

- (void)timerFired:(NSTimer *)timer
{
    //Great read on "performSelector" usage and warnings, explains the use of runtime functions below: http://stackoverflow.com/a/20058585
    id strongTarget = self.target;
    if ( strongTarget != nil )
    {
        IMP imp = [strongTarget methodForSelector:self.selector];
        if ( self.expectsTimer )
        {
            //Selector is expecting the timer, send it
            void (*func)(id, SEL, NSTimer*) = (void *)imp;
            func(strongTarget, self.selector, timer);
        }
        else
        {
            //Selector is not expecting the timer, don't send it
            void (*func)(id, SEL) = (void *)imp;
            func(strongTarget, self.selector);
        }
    }
    
    //By this time the target has either already been deallocated or we've already called our timer callback function on the target, so we're safe to invalidate the timer if it's not repeating
    if ( !self.repeats )
    {
        [self invalidate];
    }
}

- (void)invalidate
{
    //Since invalidate must be called on the thread that created it and this function could be called from any thread, tell the timer to invalidate on the thread we created it on
    if ( ![[NSThread currentThread] isEqual:self.timerThread] )
    {
        [self.timer performSelector:@selector(invalidate) onThread:self.timerThread withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self.timer invalidate];
    }
}

- (BOOL)isValid
{
    return [self.timer isValid];
}

@end
