//
//  VTrackingQueue.m
//  victorious
//
//  Created by Patrick Lynch on 10/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingQueue.h"
#import "VTrackingEvent.h"

// The maximum amount of URLs to save in memory with queued events, as wel as the maximum number of tracking requests to send in a batch/loop
static const NSUInteger kMaxQueuedUrls = 100;

@interface VTrackingQueue()

@property (nonatomic, readwrite) NSMutableArray *events;
@property (nonatomic, readonly) NSUInteger numberOfQueuedUrls;

@end

@implementation VTrackingQueue

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _events = [[NSMutableArray alloc] init];
    }
    return self;
}

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

- (BOOL)queueEventWithName:(NSString *)eventName andParameters:(NSDictionary *)parameters withKey:(id)key
{
    NSParameterAssert( key != nil );
    NSParameterAssert( eventName != nil );
    
    __block BOOL doesEventExistForKey = NO;
    [self.events enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop) {
        if ( [event.key isEqual:key] )
        {
            
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
            VLog( @"Event with duplicate key rejected.  Queued: %lu", (unsigned long)self.events.count);
#endif
            
            doesEventExistForKey = YES;
            *stop = YES;
        }
    }];
    
    if ( doesEventExistForKey )
    {
        return NO;
    }
    else
    {
        NSDictionary *completeParams = [self addTimeStampToParametersDictionary:parameters];
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithName:eventName parameters:completeParams key:key];
        [self.events addObject:event];
        
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
        VLog( @"Event queued.  Queued: %lu", (unsigned long)self.events.count);
#endif
        return YES;
    }
}

- (NSUInteger)numberOfQueuedEvents
{
    return self.events.count;
}

@end
