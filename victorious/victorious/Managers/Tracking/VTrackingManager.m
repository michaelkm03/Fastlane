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

#if TRACKING_LOGGING_ENABLED || TRACKING_QUEUE_LOGGING_ENABLED || TRACKING_ALERTS_ENABLED || TRACKING_SESSION_VALUE_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VTrackingManager ()

/**
    A dictionary a dictionaries of VTrackingEvents in the following format:
 
    {
        <eventName> :
        {
            <queueKey> : VTrackingEvent
        }
    }
 
    Events are grouped by eventName for easy access and speedy removal via the eventsForName:
    and clearQueuedEventsWithName: functions (common operations). Storing the innermost data
    (VTrackingEvents) based on a key instead of in an array also carries a significant performance
    boost over iterating an array of the events and doing a comparison on each item.
 
    QueueKey is determined based on the eventId and streamId of the provided tracking event
    by the queueKeyForEventWithParameters:eventId: function.
 */
@property (nonatomic, readwrite) NSMutableDictionary *queuedEventGroups;
@property (nonatomic, readonly) NSUInteger numberOfQueuedEvents;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableDictionary *durationEvents;
@property (nonatomic, strong) NSMutableDictionary *sessionParameters;
@property (nonatomic, strong) VTrackingEventLog *eventLog;

@end

@implementation VTrackingManager

@synthesize showTrackingEventAlerts = _showTrackingEventAlerts;
@synthesize showTrackingStartEndAlerts = _showTrackingStartEndAlerts;

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
        _queuedEventGroups = [[NSMutableDictionary alloc] init];
        _durationEvents = [[NSMutableDictionary alloc] init];
        _sessionParameters = [[NSMutableDictionary alloc] init];
        
#ifdef V_TRACKING_ALERTS
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
    self.sessionParameters[key] = value;
    
#if TRACKING_SESSION_PARAMETER_LOGGING_ENABLED
    NSLog( @"\n\nTRACKING SESSION PARAMS UPDATED: %@\n\n", [self stringFromDictionary:self.sessionParameters] );
#endif
}

- (void)clearValueForSessionParameterWithKey:(NSString *)key
{
    [self.sessionParameters removeObjectForKey:key];
    
#if TRACKING_SESSION_PARAMETER_LOGGING_ENABLED
    NSLog( @"\n\nTRACKING SESSION PARAMS UPDATED: %@\n\n", [self stringFromDictionary:self.sessionParameters] );
#endif
}

- (void)clearAllSessionParameterValues
{
    [self.sessionParameters removeAllObjects];
}

#pragma mark - Public tracking methods

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *_Nullable)parameters sessionParameters:(NSDictionary *_Nullable)sessionParameters
{
    if ( eventName == nil || eventName.length == 0 )
    {
        return;
    }
    
#ifdef V_TRACKING_ALERTS
    [self.eventLog logEvent:eventName parameters:parameters];
#endif
    
    NSDictionary *completeParams = [self addSessionParameters:sessionParameters toDictionary:parameters];
    
#if TRACKING_LOGGING_ENABLED
    NSLog( @"*** TRACKING (%lu delegates) ***\n>>> %@ <<< %@\n", (unsigned long)self.delegates.count, eventName, [self stringFromDictionary:completeParams] );
#endif
    
    if ( self.showTrackingEventAlerts )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                           [[[UIAlertView alloc] initWithTitle:eventName message:[self stringFromDictionary:completeParams]
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                       });
    }
    
    [self.delegates enumerateObjectsUsingBlock:^(id<VTrackingDelegate> delegate, NSUInteger idx, BOOL *stop)
     {
         [delegate trackEventWithName:eventName parameters:completeParams];
     }];
}

/// event name - parameters are macro replacements (see template)

- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *_Nullable)parameters
{
    [self trackEvent:eventName parameters:parameters sessionParameters:self.sessionParameters];
}

- (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName parameters:@{}];
}

- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *)parameters eventId:(NSString *)eventId
{
    [self queueEvent:eventName parameters:parameters eventId:eventId sessionParameters:self.sessionParameters];
}

- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *)parameters eventId:(NSString *)eventId sessionParameters:(NSDictionary *)sessionParameters
{
    NSParameterAssert( eventName != nil );
    
    NSMutableDictionary *eventParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [eventParameters addEntriesFromDictionary:sessionParameters];
    NSString *queueKey = [self queueKeyForEventWithParameters:eventParameters andEventId:eventId];
    NSMutableDictionary *existingQueuedEvents = self.queuedEventGroups[eventName];
    if ( existingQueuedEvents == nil )
    {
        existingQueuedEvents = [[NSMutableDictionary alloc] init];
        self.queuedEventGroups[eventName] = existingQueuedEvents;
    }
    
    if ( existingQueuedEvents[queueKey] != nil )
    {
#if TRACKING_QUEUE_LOGGING_ENABLED
        NSLog( @"Event with duplicate key rejected. Queued: %lu", (unsigned long)self.queuedEvents.count);
#endif
        return;
    }
    else
    {
        NSDictionary *completeParams = [self addTimeStampToParametersDictionary:eventParameters];
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithName:eventName parameters:completeParams eventId:eventId];
        [existingQueuedEvents setObject:event forKey:queueKey];
        [self trackEvent:event.name parameters:event.parameters];
        
#if TRACKING_QUEUE_LOGGING_ENABLED
        NSLog( @"Event queued.  Queued: %lu", (unsigned long)self.queuedEvents.count);
#endif
    }
}

- (NSString *)queueKeyForEventWithParameters:(NSDictionary *)parameters andEventId:(NSString *)eventId
{
    NSString *queueKey = eventId != nil ? eventId : @"";
    queueKey = [queueKey stringByAppendingString:@"."];
    NSString *parentContentId = parameters[VTrackingKeyParentContentId];
    if ( parentContentId != nil )
    {
        queueKey = [queueKey stringByAppendingString:parentContentId];
    }
    return queueKey;
}

- (void)clearQueuedEventsWithName:(NSString *)eventName
{
    [self.queuedEventGroups removeObjectForKey:eventName];
    
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                           [[[UIAlertView alloc] initWithTitle:@"Event Started" message:eventName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
#pragma clang diagnostic pop
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                               [[[UIAlertView alloc] initWithTitle:@"Event Ended" message:eventName delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
#pragma clang diagnostic pop
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

- (NSDictionary *)addSessionParameters:(NSDictionary *_Nullable)sessionParameters toDictionary:(NSDictionary *_Nullable)dictionary
{
    if ( sessionParameters.count == 0 )
    {
        return dictionary;
    }
    if ( dictionary == nil )
    {
        dictionary = @{};
    }
    
    NSMutableDictionary *mutable = [dictionary mutableCopy];
    [sessionParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        // Session parameters should not override parameters already inside dictionary
        if ( mutable[ key ] == nil )
        {
            mutable[ key ] = obj;
        }
    }];
    return [NSDictionary dictionaryWithDictionary:mutable];
}

- (NSArray *)eventsForName:(NSString *)eventName
{
    return [(NSDictionary *)self.queuedEventGroups[eventName] allValues];
}

- (NSUInteger)numberOfQueuedEventsForEventName:(NSString *)eventName
{
    NSArray *eventsForName = [self eventsForName:eventName];
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
    NSUInteger queuedEventsCount = 0;
    for ( NSDictionary *eventDictionary in self.queuedEventGroups.allValues )
    {
        queuedEventsCount += eventDictionary.count;
    }
    return queuedEventsCount;
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
