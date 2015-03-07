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

@end

#warning SUPPORT FOR OTHER TIMER METHODS NEEDS TO BE DONE

@implementation VTimerManager

+ (VTimerManager *)scheduledTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                                  target:(id)aTarget
                                                selector:(SEL)aSelector
                                                userInfo:(id)userInfo
                                                 repeats:(BOOL)yesOrNo
{
    NSAssert(aTarget != nil, @"Target must not be nil");
    NSAssert(aSelector != nil, @"Selector must not be nil");

    NSMethodSignature *sig = [aTarget methodSignatureForSelector:aSelector];
    NSAssert(sig != nil, @"Target must respond to selector");
    
    NSUInteger numberOfArgs = [sig numberOfArguments];
    NSAssert(numberOfArgs <= VMaxArgs, @"Selector must only expect 1 or fewer arguments");
    
    VTimerManager *timerManager = [[VTimerManager alloc] init];
    timerManager.target = aTarget;
    timerManager.selector = aSelector;
    timerManager.expectsTimer = numberOfArgs == VMaxArgs;
    timerManager.repeats = yesOrNo;
    timerManager.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:timerManager selector:@selector(timerFired:) userInfo:userInfo repeats:yesOrNo];
    return timerManager;
    
}

+ (VTimerManager *)addTimerManagerWithTimeInterval:(NSTimeInterval)timeInterval
                                            target:(id)aTarget
                                          selector:(SEL)aSelector
                                          userInfo:(id)userInfo
                                           repeats:(BOOL)yesOrNo
                                         toRunLoop:(NSRunLoop *)runLoop
                                       withRunMode:(NSString *)runMode
{
    NSAssert(aTarget != nil, @"Target must not be nil");
    NSAssert(aSelector != nil, @"Selector must not be nil");
    NSAssert(runLoop != nil, @"RunLoop must not be nil");
    NSAssert([runMode isEqualToString:NSRunLoopCommonModes] || [runMode isEqualToString:NSDefaultRunLoopMode], @"Must provide a valid runmode");
    
    NSMethodSignature *sig = [aTarget methodSignatureForSelector:aSelector];
    NSAssert(sig != nil, @"Target must respond to selector");
    
    NSUInteger numberOfArgs = [sig numberOfArguments];
    NSAssert(numberOfArgs <= VMaxArgs, @"Selector must only expect 1 or fewer arguments");
    
    VTimerManager *timerManager = [[VTimerManager alloc] init];
    timerManager.target = aTarget;
    timerManager.selector = aSelector;
    timerManager.expectsTimer = numberOfArgs == VMaxArgs;
    timerManager.repeats = yesOrNo;
    timerManager.timer = [NSTimer timerWithTimeInterval:timeInterval target:timerManager selector:@selector(timerFired:) userInfo:userInfo repeats:yesOrNo];
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
    //Invalidate must be called from the thread that was used to create the timer
    [self.timer invalidate];
}

@end
