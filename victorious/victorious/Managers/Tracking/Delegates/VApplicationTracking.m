//
//  VApplicationTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VApplicationTracking.h"
#import "VObjectManager+Private.h"
#import "VTrackingURLRequest.h"

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

static const NSUInteger kMaximumURLRequestRetryCount = 5;

#define APPLICATION_TRACKING_LOGGING_ENABLED 1

#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VApplicationTracking()

@property (nonatomic, readonly) NSDictionary *parameterMacroMapping;

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
                                    VTrackingKeyVoteCount          : kMacroBallisticsCount,
                                    VTrackingKeyPositionX          : kMacroPositionX,
                                    VTrackingKeyPositionY          : kMacroPositionY,
                                    VTrackingKeyNavigiationFrom    : kMacroNavigiationFrom,
                                    VTrackingKeyNavigiationTo      : kMacroNavigiationTo };
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

- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters
{
    BOOL isUrlValid = url != nil && [url isKindOfClass:[NSString class]] && url.length > 0;
    if ( !isUrlValid )
    {
        return NO;
    }
    
    NSString *urlWithMacrosReplaced = [self stringByReplacingMacros:self.parameterMacroMapping
                                                           inString:url
                                         withCorrspondingParameters:parameters];
    if ( !urlWithMacrosReplaced )
    {
        return NO;
    }
    
    
    VObjectManager *objManager = [self applicationObjectManager];
    VTrackingURLRequest *request = [self requestWithUrl:urlWithMacrosReplaced objectManager:objManager];
    if ( request == nil )
    {
        return NO;
    }
    
    [self sendRequest:request];
    
    return YES;
}

- (VObjectManager *)applicationObjectManager
{
    return [VObjectManager sharedManager];
}

- (NSString *)stringByReplacingMacros:(NSDictionary *)macros inString:(NSString *)originalString withCorrspondingParameters:(NSDictionary *)parameters
{
    // Optimization
    if ( !parameters|| parameters.allKeys.count == 0 )
    {
        return originalString;
    }
    
    __block NSString *output = originalString;
    
    [macros enumerateKeysAndObjectsUsingBlock:^(NSString *macroKey, NSString *macroValue, BOOL *stop) {
        
        // For each macro, find a value in the parameters dictionary
        id value = parameters[ macroValue ];
        if ( value != nil )
        {
            NSString *stringWithNextMacro = [self stringFromString:output byReplacingString:macroValue withValue:value];
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
        if ( CFNumberIsFloatType( (CFNumberRef)value ) )
        {
            replacementValue = [NSString stringWithFormat:@"%.2f", ((NSNumber *)value).floatValue];
        }
        else
        {
            replacementValue = [NSString stringWithFormat:@"%i", ((NSNumber *)value).intValue];
        }
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

- (void)sendRequest:(NSURLRequest *)request
{
    if ( request == nil )
    {
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if ( [request isMemberOfClass:[VTrackingURLRequest class]] )
         {
             VTrackingURLRequest *trackingRequest = (VTrackingURLRequest *)request;
             if ( connectionError && ++trackingRequest.retriesCount <= kMaximumURLRequestRetryCount )
             {
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
                 VLog( @"TRACKING :: RETRING %lu :: URL %@.", (unsigned long)((VTrackingURLRequest *)request).retriesCount, request.URL.absoluteString );
#endif
                 [self sendRequest:request];
             }
         }
         
         
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
         if ( connectionError )
         {
             VLog( @"TRACKING :: ERROR with URL %@ :: %@", request.URL.absoluteString, [connectionError localizedDescription] );
         }
         else
         {
             VLog( @"TRACKING :: SUCCESS with URL %@", request.URL.absoluteString );
         }
#endif
     }];
}

- (VTrackingURLRequest *)requestWithUrl:(NSString *)urlString objectManager:(VObjectManager *)objectManager
{
    NSParameterAssert( objectManager != nil );
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ( !url )
    {
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
        VLog( @"TRACKING :: ERROR :: Invalid URL %@.", urlString );
#endif
        return nil;
    }
    
    VTrackingURLRequest *request = [VTrackingURLRequest requestWithURL:url];
    [objectManager updateHTTPHeadersInRequest:request];
    request.HTTPBody = nil;
    request.HTTPMethod = @"GET";
    return request;
}

#pragma mark - VTrackingDelegate

- (void)trackEventWithName:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    NSArray *urls = parameters[ VTrackingKeyUrls ];
    if ( urls )
    {
        [self trackEventWithUrls:urls andParameters:parameters];
    }
}

@end
