//
//  VTrackingManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrackingManager.h"
#import <AFNetworking/AFNetworking.h>

#define LOG_TRACKING_EVENTS 1

@interface VTrackingManager()

@property (nonatomic, readonly) NSArray *registeredMacros;

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
    }
    return self;
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

- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters
{
    BOOL areUrlsValid = urls != nil && [urls isKindOfClass:[NSArray class]] && urls.count > 0;
    if ( !areUrlsValid  )
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

- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters
{
    BOOL isUrlValid = url != nil && [url isKindOfClass:[NSString class]] && url.length > 0;
    if ( !isUrlValid )
    {
        return NO;
    }
    
    NSString *urlWithMacrosReplaced = [self stringByReplacingMacros:self.registeredMacros
                                                           inString:url
                                         withCorrspondingParameters:parameters];
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

- (void)sendRequestWithUrlString:(NSString *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
#if LOG_TRACKING_EVENTS
         if ( connectionError )
         {
             VLog( @"TRACKING :: FAILSURE with URL %@:: error %@", url, [connectionError localizedDescription] );
         }
         else
         {
             VLog( @"TRACKING :: SUCCESS with URL %@", url );
         }
#endif
     }];
}

@end
