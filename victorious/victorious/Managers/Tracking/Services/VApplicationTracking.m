//
//  VApplicationTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VApplicationTracking.h"
#import "VObjectManager+Private.h"
#import <AFNetworking/AFNetworking.h>

NSString * const kMacroTimeFrom               = @"%%FROM_TIME%%";
NSString * const kMacroTimeTo                 = @"%%TO_TIME%%";
NSString * const kMacroTimeCurrent            = @"%%TIME_CURRENT%%";
NSString * const kMacroTimeStamp              = @"%%TIME_STAMP%%";
NSString * const kMacroPageLabel              = @"%%PAGE%%";
NSString * const kMacroPositionX              = @"%%XPOS%%";
NSString * const kMacroPositionY              = @"%%YPOS%%";
NSString * const kMacroNavigiationFrom        = @"%%NAV_FROM%%";
NSString * const kMacroNavigiationTo          = @"%%NAV_TO%%";
NSString * const kMacroStreamId               = @"%%STREAM_ID%%";
NSString * const kMacroSequenceId             = @"%%SEQUENCE_ID%%";
NSString * const kMacroBallisticsCount        = @"%%COUNT%%";

static const BOOL kLogTrackingEvents = NO;

@interface VApplicationTracking()

@property (nonatomic, readonly) NSDictionary *parameterMacroMapping;
@property (nonatomic, strong) NSMutableArray *queuedTrackingEvents;

@end

@implementation VApplicationTracking

#pragma mark - Init and dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // This is a mapping of generic parameters to application-specific macros
        _parameterMacroMapping = @{ VTrackingKeyTimeFrom           : kMacroTimeFrom,
                                    VTrackingKeyTimeTo             : kMacroTimeTo,
                                    VTrackingKeyTimeCurrent        : kMacroTimeCurrent,
                                    VTrackingKeyTimeStamp          : kMacroTimeStamp,
                                    VTrackingKeyPageLabel          : kMacroPageLabel,
                                    VTrackingKeyStreamId           : kMacroStreamId,
                                    VTrackingKeySequenceId         : kMacroSequenceId,
                                    VTrackingKeyVoteCount    : kMacroBallisticsCount,
                                    VTrackingKeyPositionX          : kMacroPositionX,
                                    VTrackingKeyPositionY          : kMacroPositionY,
                                    VTrackingKeyNavigiationFrom    : kMacroNavigiationFrom,
                                    VTrackingKeyNavigiationTo      : kMacroNavigiationTo };
        
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
            
            if ( kLogTrackingEvents )
            {
                VLog( @"Event with duplicate key rejected.  Queued: %lu", (unsigned long)self.queuedTrackingEvents.count);
            }
            
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
        VTrackingEvent *event = [[VTrackingEvent alloc] initWithUrls:urls parameters:completeParams key:key];
        [self.queuedTrackingEvents addObject:event];
        
        // TODO: Keep memory consumption low somehow, don't let too many events build up, but clear the queue too early
        
        if ( kLogTrackingEvents )
        {
            VLog( @"Event queued.  Queued: %lu", (unsigned long)self.queuedTrackingEvents.count);
        }
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
    
    if ( kLogTrackingEvents )
    {
        VLog( @"Sent queued event. Queue: %lu", (unsigned long)self.queuedTrackingEvents.count);
    }
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
    
    NSString *urlWithMacrosReplaced = [self stringByReplacingMacros:self.parameterMacroMapping.allValues
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
        replacementValue = [NSString stringWithFormat:@"%.2f@", ((NSNumber *)value).floatValue];
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
    
    if ( dictionary[ kMacroTimeStamp ] )
    {
        return dictionary;
    }
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [mutable setObject:[NSDate date] forKey:kMacroTimeStamp];
    return [NSDictionary dictionaryWithDictionary:mutable];
}

- (void)sendRequestWithUrlString:(NSString *)url
{
    NSURLRequest *request = [self requestWithUrl:url objectManager:[VObjectManager sharedManager]];
    if ( request == nil )
    {
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if ( kLogTrackingEvents )
         {
             if ( connectionError )
             {
                 VLog( @"TRACKING :: ERROR with URL %@ :: %@", url, [connectionError localizedDescription] );
             }
             else
             {
                 VLog( @"TRACKING :: SUCCESS with URL %@", url );
             }
         }
     }];
}

- (NSURLRequest *)requestWithUrl:(NSString *)urlString objectManager:(VObjectManager *)objectManager
{
    if ( objectManager == nil )
    {
        if ( kLogTrackingEvents )
        {
            VLog( @"TRACKING :: ERROR unable to create request for URL %@ using a nil object manager.", urlString );
        }
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ( !url )
    {
        if ( kLogTrackingEvents )
        {
            VLog( @"TRACKING :: ERROR :: Invalid URL %@.", urlString );
        }
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [objectManager updateHTTPHeadersInRequest:request];
    request.HTTPBody = nil;
    request.HTTPMethod = @"GET";
    return request;
}


@end
