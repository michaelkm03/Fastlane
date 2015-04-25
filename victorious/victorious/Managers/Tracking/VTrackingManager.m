//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VTrackingEvent.h"
#import "VTrackingEventLog.h"

#define TRACKING_LOGGING_ENABLED 0
#define TRACKING_EVENT_ALERTS_ENABLED 0
#define TRACKING_START_END_ALERTS_ENABLED 0
#define TRACKING_QUEUE_LOGGING_ENABLED 0
#define TRACKING_SESSION_PARAMETER_LOGGING_ENABLED 0
#define TRACKING_VIEW_SESSION_LOGGING_ENABLED 0

#if TRACKING_LOGGING_ENABLED || TRACKING_QUEUE_LOGGING_ENABLED || TRACKING_ALERTS_ENABLED || TRACKING_VIEW_SESSION_LOGGING_ENABLED || TRACKING_SESSION_VALUE_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VTrackingManager ()

@property (nonatomic, readwrite) NSMutableArray *queuedEvents;
@property (nonatomic, readonly) NSUInteger numberOfQueuedEvents;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableDictionary *durationEvents;
@property (nonatomic, strong) NSMutableDictionary *sessionParameters;
@property (nonatomic, strong) VTrackingEventLog *eventLog;

@end

@implementation VTrackingManager

+ (VTrackingManager *)sharedInstance
{
    static VTrackingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      instance = [[VTrackingManager alloc] init];
                  });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _delegates = [[NSMutableArray alloc] init];
        _queuedEvents = [[NSMutableArray alloc] init];
        _durationEvents = [[NSMutableDictionary alloc] init];
        _sessionParameters = [[NSMutableDictionary alloc] init];
        
#ifndef V_NO_TRACKING_ALERTS
        _eventLog = [[VTrackingEventLog alloc] init];
        [_eventLog clearEvents];
#endif
    }
    return self;
}

- (NSString *)stringFromDictionary:(NSDictionary *)dictionary
{
    NSUInteger numSpaces = 17;
    NSString *output = @"";
    for ( NSString *key in dictionary )
    {
        id value = dictionary[key];
        if ( [value isKindOfClass:[NSArray class]] )
        {
            NSArray *arrayValue = (NSArray *)value;
            NSString *stringValue = [NSString stringWithFormat:@"%@", arrayValue.firstObject];
            for ( NSUInteger i = 0; i < MAX( numSpaces - key.length, (NSUInteger)0); i++ )
            {
                stringValue = [@" " stringByAppendingString:stringValue];
            }
            output = [output stringByAppendingFormat:@"\n\t%@:%@", key, stringValue];
            for ( NSUInteger i = 1; i < arrayValue.count; i++ )
            {
                id itemValue = arrayValue[i];
                for ( NSUInteger i = 0; i < MAX( numSpaces - key.length, (NSUInteger)0); i++ )
                {
                    output = [output stringByAppendingString:@" "];
                }
                output = [output stringByAppendingFormat:@"\n\t%@", itemValue];
            }
        }
        else
        {
            NSString *stringValue = [NSString stringWithFormat:@"%@", value];
            for ( NSUInteger i = 0; i < MAX( numSpaces - key.length, (NSUInteger)0); i++ )
            {
                stringValue = [@" " stringByAppendingString:stringValue];
            }
            output = [output stringByAppendingFormat:@"\n\t%@:%@", key, stringValue];
        }
    }
    return output;
}

- (BOOL)showTrackingEventAlerts
{
#if TRACKING_EVENT_ALERTS_ENABLED
    return YES;
#endif
    return _showTrackingEventAlerts;
}

- (BOOL)showTrackingStartEndAlerts
{
#if TRACKING_START_END_ALERTS_ENABLED
    return YES;
#endif
    return _showTrackingStartEndAlerts;
}

#pragma mark - Session Parameters

- (void)setValue:(id)value forSessionParameterWithKey:(NSString *)key
{
    if ( value == nil )
    {
        [self.sessionParameters removeObjectForKey:key];
    }
    else
    {
        self.sessionParameters[key] = value;
    }
#if TRACKING_SESSION_PARAMETER_LOGGING_ENABLED
    NSLog( @"\n\nTRACKING SESSION PARAMS UPDATED: %@\n\n", [self stringFromDictionary:self.sessionParameters] );
#endif
}

- (void)clearSessionParameters
{
    [self.sessionParameters removeAllObjects];
}

#pragma mark - Public tracking methods

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( eventName == nil || eventName.length == 0 )
    {
        return;
    }
#ifndef V_NO_TRACKING_ALERTS
    [self.eventLog logEvent:eventName parameters:parameters];
#endif
    
    NSDictionary *completeParams = [self addSessionParametersToDictionary:parameters];
    
#if TRACKING_LOGGING_ENABLED
    NSLog( @"*** TRACKING (%lu delegates) ***\n>>> %@ <<< %@\n", (unsigned long)self.delegates.count, eventName, [self stringFromDictionary:completeParams] );
#endif
    
    if ( self.showTrackingEventAlerts )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [[[UIAlertView alloc] initWithTitle:eventName message:[self stringFromDictionary:completeParams]
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                       });
    }
    
    [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
     {
         [delegate trackEventWithName:eventName parameters:completeParams];
     }];
}

- (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName parameters:@{}];
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
             
#if TRACKING_QUEUE_LOGGING_ENABLED
             NSLog( @"Event with duplicate key rejected.  Queued: %lu", (unsigned long)self.queuedEvents.count);
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
        [self trackEvent:event.name parameters:event.parameters];
        
#if TRACKING_QUEUE_LOGGING_ENABLED
        NSLog( @"Event queued.  Queued: %lu", (unsigned long)self.queuedEvents.count);
#endif
    }
}

- (void)dequeuedAllEvents
{
    [self trackEvents:self.queuedEvents];
    self.queuedEvents = [[NSMutableArray alloc] init];
}

- (void)clearQueuedEventsWithName:(NSString *)eventName
{
    NSArray *eventsForName = [self eventsForName:eventName fromQueue:self.queuedEvents];
    [eventsForName enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop)
     {
         [self.queuedEvents removeObject:event];
     }];
    
#if TRACKING_QUEUE_LOGGING_ENABLED
    NSLog( @"Dequeued events:  %lu remain", (unsigned long)self.queuedEvents.count);
#endif
}

- (void)startEvent:(NSString *)eventName
{
    [self startEvent:eventName parameters:@{}];
}

- (void)startEvent:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [self endEvent:eventName];
    
    if ( self.showTrackingStartEndAlerts )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [[[UIAlertView alloc] initWithTitle:@"Event Started" message:eventName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                       });
        NSLog( @"Event Started: %@ to %lu delegates", eventName, (unsigned long)self.delegates.count);
    }
    
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
        if ( self.showTrackingStartEndAlerts )
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                           {
                               [[[UIAlertView alloc] initWithTitle:@"Event Ended" message:eventName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                           });
            NSLog( @"Event Ended: %@ to %lu delegates", eventName, (unsigned long)self.delegates.count);
        }
        
        __block NSTimeInterval duration = ABS( [event.dateCreated timeIntervalSinceNow] );
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
        dictionary = @{};
    }
    
    if ( dictionary[ VTrackingKeyTimeStamp ] )
    {
        return dictionary;
    }
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutable setObject:[NSDate date] forKey:VTrackingKeyTimeStamp];
    return [NSDictionary dictionaryWithDictionary:mutable];
}

- (NSDictionary *)addSessionParametersToDictionary:(NSDictionary *)dictionary
{
    if ( self.sessionParameters.count == 0 )
    {
        return dictionary;
    }
    if ( dictionary == nil )
    {
        dictionary = @{};
    }
    
    NSMutableDictionary *mutable = [dictionary mutableCopy];
    [self.sessionParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        // Session parameters should not override parameters already inside dictionary
        if ( mutable[ key ] == nil )
        {
            mutable[ key ] = obj;
        }
    }];
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
    if ( ![self.delegates containsObject:delegate] )
    {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<VTrackingDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

- (void)removeAllDelegates
{
    [self.delegates removeAllObjects];
}

@end
