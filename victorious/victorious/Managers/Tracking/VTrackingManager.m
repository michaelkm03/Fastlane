//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import "VObjectManager+Private.h"
#import <AFNetworking/AFNetworking.h>

#define LOG_TRACKING_EVENTS 1

@interface VTrackingManager()

@property (nonatomic, readonly) NSArray *registeredMacros;
@property (nonatomic, strong) NSMutableArray *queuedTrackingEvents;

@end

@implementation VTrackingManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _registeredMacros = @[ kTrackingKeyTimeFrom,
                               kTrackingKeyTimeTo,
                               kTrackingKeyTimeCurrent,
                               kTrackingKeyTimeStamp,
                               kTrackingKeyPageLabel,
                               kTrackingKeyStreamId,
                               kTrackingKeySequenceId,
                               kTrackingKeyBallisticsCount,
                               kTrackingKeyPositionX,
                               kTrackingKeyPositionY,
                               kTrackingKeyNavigiationFrom,
                               kTrackingKeyNavigiationTo ];
        
        self.queuedTrackingEvents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if ( !self.shouldIgnoreEventsInQueueOnDealloc )
    {
        [self sendQueuedTrackingEvents];
    }
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      dateFormatter = [[NSDateFormatter alloc] init];
                      dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                      dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                      dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                  });
    return dateFormatter;
}

- (NSString *)percentEncodedUrlString:(NSString *)originalUrl
{
    if ( !originalUrl )
    {
        return nil;
    }
    
    NSString *output = originalUrl;
    output = [output stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    output = [output stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    output = [output stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
    return output;
}

- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters
{
    if ( ![self validateUrls:urls]  )
    {
        return -1;
    }
    
    __block NSUInteger numFailures = 0;
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop)
    {
        if ( ![self trackEventWithUrl:url andParameters:parameters] )
        {
            numFailures++;
        }
    }];
    
    return numFailures;
}

- (BOOL)validateUrls:(NSArray *)urls
{
    return urls != nil && [urls isKindOfClass:[NSArray class]] && urls.count > 0;
}

- (BOOL)queueEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters withKey:(id)key
{
    NSParameterAssert( key != nil );
    
    if ( ![self validateUrls:urls] )
    {
        return NO;
    }
    
    __block BOOL doesEventExistForKey = NO;
    [self.queuedTrackingEvents enumerateObjectsUsingBlock:^(VTrackingEvent *event, NSUInteger idx, BOOL *stop) {
        if ( [event.key isEqual:key] )
        {
            
#if LOG_TRACKING_EVENTS
            VLog( @"Event with duplicate key rejected.  Queued: %lu", (unsigned long)self.queuedTrackingEvents.count);
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
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithUrls:urls parameters:parameters key:key];
        [self.queuedTrackingEvents addObject:event];
        
        // TODO: Keep memory consumption low somehow, don't let too many events build up, but clear the queue too early
        
#if LOG_TRACKING_EVENTS
        VLog( @"Event queued.  Queued: %lu", (unsigned long)self.queuedTrackingEvents.count);
#endif
        return YES;
    }
}

- (void)popFrontOfQueue
{
    VTrackingEvent *event = self.queuedTrackingEvents.firstObject;
    [self trackEventWithUrls:event.urls andParameters:event.parameters];
    [self.queuedTrackingEvents removeObjectAtIndex:0];
}

- (void)sendQueuedTrackingEvents
{
    while ( self.queuedTrackingEvents.count > 0 )
    {
        [self popFrontOfQueue];
    }
    
#if LOG_TRACKING_EVENTS
    VLog( @"Sent queued event. Queue: %lu", (unsigned long)self.queuedTrackingEvents.count);
#endif
}

- (NSUInteger)numberOfQueuedEvents
{
    return self.queuedTrackingEvents.count;
}

- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters
{
    BOOL isUrlValid = url != nil && [url isKindOfClass:[NSString class]] && url.length > 0;
    if ( !isUrlValid )
    {
        return NO;
    }
    
    NSDictionary *completeParams = [self addTimeStampToParametersDictionary:parameters];
    
    NSString *urlWithMacrosReplaced = [self stringByReplacingMacros:self.registeredMacros
                                                           inString:url
                                         withCorrspondingParameters:completeParams];
    if ( !urlWithMacrosReplaced )
    {
        return NO;
    }
    
    [self sendRequestWithUrlString:urlWithMacrosReplaced];
    
    return YES;
}

- (NSString *)stringByReplacingMacros:(NSArray *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters
{
    // Optimization
    if ( !parameters|| parameters.allKeys.count == 0 )
    {
        return originalString;
    }
    
    __block NSString *output = originalString;
    
    [macros enumerateObjectsUsingBlock:^(NSString *macro, NSUInteger idx, BOOL *stop)
    {
        // For each macro, find a value in the parameters dictionary
        id value = parameters[ macro ];
        if ( value != nil )
        {
            NSString *stringWithNextMacro = [self stringFromString:output byReplacingString:macro withValue:value];
            if ( stringWithNextMacro != nil )
            {
                output = stringWithNextMacro;
            }
        }
    }];
    
    return output;
}

- (NSString *)stringFromString:(NSString *)originalString byReplacingString:(NSString *)stringToReplace withValue:(id)value
{
    NSParameterAssert( originalString && originalString.length > 0 );
    NSParameterAssert( stringToReplace && stringToReplace.length > 0 );
    
    NSString *replacementValue = nil;
    
    if ( [value isKindOfClass:[NSDate class]] )
    {
        replacementValue = [self.dateFormatter stringFromDate:(NSDate *)value];
        replacementValue = [self percentEncodedUrlString:replacementValue];
    }
    else if ( [value isKindOfClass:[NSNumber class]] )
    {
        replacementValue = [NSString stringWithFormat:@"%@", (NSNumber *)value];
    }
    else if ( [value isKindOfClass:[NSString class]] && ((NSString *)value).length > 0 )
    {
        replacementValue = value;
    }
    
    if ( !replacementValue )
    {
        return nil;
    }
    
    return [originalString stringByReplacingOccurrencesOfString:stringToReplace withString:replacementValue];
}

- (NSDictionary *)addTimeStampToParametersDictionary:(NSDictionary *)dictionary
{
    if ( dictionary == nil )
    {
        return nil;
    }
    
    if ( dictionary[ kTrackingKeyTimeStamp ] )
    {
        return dictionary;
    }
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutable setObject:[NSDate date] forKey:kTrackingKeyTimeStamp];
    return [NSDictionary dictionaryWithDictionary:mutable];
}

- (void)sendRequestWithUrlString:(NSString *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[VObjectManager sharedManager] updateHTTPHeadersInRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
#if LOG_TRACKING_EVENTS
         if ( connectionError )
         {
             VLog( @"TRACKING :: FAILURE with URL %@:: error %@", url, [connectionError localizedDescription] );
         }
         else
         {
             VLog( @"TRACKING :: SUCCESS with URL %@", url );
         }
#endif
     }];
}

@end
