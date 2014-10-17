//
//  VAnalyticsManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsManager.h"

@interface VAnalyticsManager()

@property (nonatomic, readonly) NSArray *registeredMacros;

@end

@implementation VAnalyticsManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _registeredMacros = @[ kAnalyticsKeyTimeFrom,
                               kAnalyticsKeyTimeTo,
                               kAnalyticsKeyUserTime,
                               kAnalyticsKeyPageLAbel,
                               kAnalyticsKeyStreamName,
                               kAnalyticsKeyPositionX,
                               kAnalyticsKeyPositionY,
                               kAnalyticsKeyNavigiationFrom,
                               kAnalyticsKeyNavigiationTo ];
    }
    return self;
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
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
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL *stop) {
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
    if ( urlWithMacrosReplaced == nil )
    {
        return NO;
    }
    
    VLog( @"Track event with URL: %@", urlWithMacrosReplaced );
    return YES;
}

- (NSString *)stringByReplacingMacros:(NSArray *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters
{
    // Optimization
    if ( parameters == nil || parameters.allKeys.count == 0 )
    {
        return originalString;
    }
    
    __block NSString *output = originalString;
    
    [macros enumerateObjectsUsingBlock:^(NSString *macro, NSUInteger idx, BOOL *stop) {
        
        // For each macro, find a value in the parameters dictionary
        id value = parameters[ macro ];
        if ( value != nil )
        {
            output = [self stringFromString:output byReplacingString:macro withValue:value];
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
    else if ( [value isKindOfClass:[NSString class]] )
    {
        replacementValue = value;
    }
    
    NSAssert( replacementValue != nil && replacementValue.length > 0, @"Value must be convertible to a valid string by one of the previous techniues." );
    
    return [originalString stringByReplacingOccurrencesOfString:stringToReplace withString:replacementValue];
}

@end
