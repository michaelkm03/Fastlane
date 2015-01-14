//
//  VTrimmedPlayer.m
//  victorious
//
//  Created by Michael Sena on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTrimmedPlayer.h"

@interface VTrimmedPlayer ()

@property (nonatomic, strong) id perFrameTimeObserver;

@property (nonatomic, assign, getter=isSeeking) BOOL seeking;

@property (nonatomic, strong) dispatch_queue_t timeObserverQueue;

@end

@implementation VTrimmedPlayer

#pragma mark - Intializer/Factory

+ (instancetype)playerWithURL:(NSURL *)URL
{
    return [[self alloc] initWithURL:URL];
}

+ (instancetype)playerWithPlayerItem:(AVPlayerItem *)item
{
    return [[self alloc] initWithPlayerItem:item];
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item
{
    self = [super initWithPlayerItem:item];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
#warning Remove me if I don't end up being used
    _timeObserverQueue = dispatch_queue_create("VTrimmedPlayer time observer queue", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Property Accessors

- (void)setTrimRange:(CMTimeRange)trimRange
{
    _trimRange = trimRange;
    
    if (self.perFrameTimeObserver)
    {
        [self removeTimeObserver:self.perFrameTimeObserver];
    }
    
    __weak typeof(self) welf = self;
    self.perFrameTimeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 30)
                                                                   queue:NULL
                                                              usingBlock:^(CMTime time)
                                 {
                                     [welf.delegate trimmedPlayerPlayedToTime:time
                                                                trimmedPlayer:welf];
                                     
                                     VLog(@"Played to time: %@, trimRange: %@", [NSValue valueWithCMTime:time], [NSValue valueWithCMTimeRange:[welf trimRange]]);
                                     if (CMTIME_COMPARE_INLINE(time, >, [welf trimEndTime]))
                                     {
                                         [welf seekToBeginningOfTrimRange];
                                     }
                                     else if (CMTIME_COMPARE_INLINE(time, <, [welf trimRange].start))
                                     {
                                         [welf seekToBeginningOfTrimRange];
                                     }
                                 }];
}

#pragma mark - Private Methods

- (void)seekToBeginningOfTrimRange
{
    if (self.isSeeking)
    {
        return;
    }
    
    VLog(@"Seeking to beginning");
    [self pause];
    self.seeking = YES;
    [self seekToTime:self.trimRange.start
   completionHandler:^(BOOL finished)
    {
        if (finished)
        {
            self.seeking = NO;
            VLog(@"finished seeking");
            [self play];
        }
    }];
}

- (CMTime)trimEndTime
{
    return CMTimeAdd(self.trimRange.start, self.trimRange.duration);
}

@end
