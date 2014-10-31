//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VTrackingEvent.h"

#define TRACKING_LOGGING_ENABLED 1

#if DEBUG && TRACKING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

#define TRACKING_ALERTS_ENABLED 0

#if DEBUG && TRACKING_ALERTS_ENABLED
#import "UIAlertView+VBlocks.h"
#warning Tracking alerts are enabled!
#endif

@interface VTrackingManager ()

@property (nonatomic, readwrite) NSMutableArray *queuedEvents;
@property (nonatomic, readonly) NSUInteger numberOfQueuedEvents;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableDictionary *durationEvents;

@end

static VTrackingManager *_sharedInstance;

@implementation VTrackingManager

+ (VTrackingManager *)sharedInstance
{
    if ( _sharedInstance == nil )
    {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (void)deallocateSharedInstance
{
    _sharedInstance = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _delegates = [[NSMutableArray alloc] init];
        _queuedEvents = [[NSMutableArray alloc] init];
        _durationEvents = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Public tracking methods

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( eventName == nil )
    {
        return;
    }
    
#if DEBUG && TRACKING_LOGGING_ENABLED
    VLog( @"Tracking: %@ to %lu delegates", eventName, (unsigned long)self.delegates.count);
#endif

#if DEBUG && TRACKING_ALERTS_ENABLED
    NSString *title = @"Event Tracked";
    __block NSString *message = [NSString stringWithFormat:@"Event:%@", eventName];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        message = [message stringByAppendingFormat:@"\n%@ = %@", key, obj];
    }];
    [[[UIAlertView alloc] initWithTitle:title message:message cancelButtonTitle:@"OK" onCancelButton:nil otherButtonTitlesAndBlocks:nil] show];
#endif
    
    [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
     {
         [delegate trackEventWithName:eventName parameters:parameters];
     }];
}

- (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName parameters:nil];
}

- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *)parameters eventId:(id)eventId
{
    NSParameterAssert( eventName != nil );
    
    __block BOOL doesEventExistForKey = NO;
    [self.queuedEvents enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop)
     {
         BOOL matchesEventId = [event.eventId isEqual:eventId] || eventId == nil;
         BOOL matchesEventName = event.name == eventName;
         if ( matchesEventId && matchesEventName )
         {
             
#if DEBUG && TRACKING_LOGGING_ENABLED
             VLog( @"Event with duplicate key rejected.  Queued: %lu", (unsigned long)self.queuedEvents.count);
#endif
             
             doesEventExistForKey = YES;
             *stop = YES;
         }
     }];
    
    if ( doesEventExistForKey )
    {
        return;
    }
    else
    {
        NSDictionary *completeParams = [self addTimeStampToParametersDictionary:parameters];
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithName:eventName parameters:completeParams eventId:eventId];
        [self.queuedEvents addObject:event];
        
#if DEBUG && TRACKING_LOGGING_ENABLED
        VLog( @"Event queued.  Queued: %lu", (unsigned long)self.queuedEvents.count);
#endif
    }
}

- (void)dequeuedAllEvents
{
    [self trackEvents:self.queuedEvents];
    self.queuedEvents = [[NSMutableArray alloc] init];
}

- (void)trackQueuedEventsWithName:(NSString *)eventName
{
    NSArray *eventsForName = [self eventsForName:eventName fromQueue:self.queuedEvents];
    [self trackEvents:eventsForName];
    [eventsForName enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop)
     {
         [self.queuedEvents removeObject:event];
     }];
    
#if DEBUG && TRACKING_LOGGING_ENABLED
    VLog( @"Dequeued events:  %lu remain", (unsigned long)self.queuedEvents.count);
#endif
}

- (void)startEvent:(NSString *)eventName
{
    [self startEvent:eventName parameters:nil];
}

- (void)startEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [self endEvent:eventName];
    
#if DEBUG && TRACKING_LOGGING_ENABLED
    VLog( @"Event Started: %@ to %lu delegates", eventName, (unsigned long)self.delegates.count);
#endif
    
    VTrackingEvent *event = [[VTrackingEvent alloc] initWithName:eventName parameters:parameters eventId:nil];
    self.durationEvents[ eventName ] = event;
    
    [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
     {
         if ( [delegate respondsToSelector:@selector(eventStarted:parameters:)] )
         {
             [delegate eventStarted:eventName parameters:parameters];
         }
     }];
}

- (void)endEvent:(NSString *)eventName
{
    __block VTrackingEvent *event = self.durationEvents[ eventName ];
    if ( event )
    {
#if DEBUG && TRACKING_LOGGING_ENABLED
        VLog( @"Event Ended: %@ to %lu delegates", eventName, (unsigned long)self.delegates.count);
#endif
        __block NSTimeInterval duration = abs( [event.dateCreated timeIntervalSinceNow] );
        [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
         {
             if ( [delegate respondsToSelector:@selector(eventEnded:parameters:duration:)] )
             {
                 [delegate eventEnded:event.name parameters:event.parameters duration:duration];
             }
         }];
        
        [self.durationEvents removeObjectForKey:eventName];
    }
}

#pragma mark - Helpers

- (NSDictionary *)addTimeStampToParametersDictionary:(NSDictionary *)dictionary
{
    if ( dictionary == nil )
    {
        return nil;
    }
    
    if ( dictionary[ VTrackingKeyTimeStamp ] )
    {
        return dictionary;
    }
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutable setObject:[NSDate date] forKey:VTrackingKeyTimeStamp];
    return [NSDictionary dictionaryWithDictionary:mutable];
}

- (NSArray *)eventsForName:(NSString *)eventName fromQueue:(NSArray *)queue
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", eventName];
    return [queue filteredArrayUsingPredicate:predicate];
}

- (NSUInteger)numberOfQueuedEventsForEventName:(NSString *)eventName
{
    NSArray *eventsForName = [self eventsForName:eventName fromQueue:self.queuedEvents];
    return eventsForName.count;
}

- (void)trackEvents:(NSArray *)eventsArray
{
    [eventsArray enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop)
     {
         [self trackEvent:event.name parameters:event.parameters];
     }];
}

- (NSUInteger)numberOfQueuedEvents
{
    return self.queuedEvents.count;
}

#pragma mark - Delegate Management

- (void)addDelegate:(id<VTrackingDelegate>)delegate
{
    [self.delegates addObject:delegate];
}

- (void)removeService:(id<VTrackingDelegate>)delegate
{
    [self.delegates removeObject:delegate];
    
    if ( self.delegates.count == 0 )
    {
        [VTrackingManager deallocateSharedInstance];
    }
}

- (void)removeAllServices
{
    [self.delegates removeAllObjects];
    
    [VTrackingManager deallocateSharedInstance];
}

@end
