//
//  VInteractionManager.m
//  victorious
//
//  Created by Will Long on 3/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInteractionManager.h"

#import "VInteraction.h"
#import "VNode+Fetcher.h"

@interface VInteractionManager()

@property (strong, nonatomic) NSArray *interactions;
@property (strong, nonatomic) NSMutableArray *timers;
@property (nonatomic) CGFloat lastInteractionTimeout;

@property (nonatomic) CGFloat pauseTime;

@end

@implementation VInteractionManager

- (instancetype)initWithNode:(VNode *)node delegate:(id<VInteractionManagerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.node = node;
        self.interactions = node.interactions.array;
    }
    return self;
}

- (void)setNode:(VNode *)node
{
    _node = node;
    self.lastInteractionTimeout = 0;
    for (VInteraction *interaction in self.interactions)
    {
        if (interaction.timeout.floatValue > self.lastInteractionTimeout)
        {
            self.lastInteractionTimeout = interaction.timeout.floatValue / 1000;
        }
        
        if (interaction.startTime.integerValue == -1)
        {
            [self.delegate firedInteraction:interaction];
        }
    }
}

- (void)startInteractionTimerAtTime:(CGFloat)currentTime
{
    for (VInteraction *interaction in self.interactions)
    {
        //don't set a timer if we've already passed the interaction...
        if (currentTime >  (interaction.startTime.floatValue + interaction.timeout.floatValue) / 1000)
        {
            continue;
        }
        NSTimeInterval timeUntilInteraction = NSTimeIntervalSince1970 - currentTime + (interaction.startTime.floatValue / 1000);
        NSTimer *newTimer = [NSTimer timerWithTimeInterval:timeUntilInteraction target:self selector:@selector(timerFiredInteraction:) userInfo:interaction repeats:NO];
        [self.timers addObject:newTimer];
    }
}

- (void)pauseInterationTimer
{
    for (NSTimer *timer in self.timers)
    {
        [timer invalidate];
    }
    [self.timers removeAllObjects];
}

- (void)timerFiredInteraction:(NSTimer *)timer
{
    [self.delegate firedInteraction:timer.userInfo];
}

@end
