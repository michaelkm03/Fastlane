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

static NSString * const kMacroBookendToken           = @"%%";

static NSString * const kMacroFromTime               = @"%%FROM_TIME%%";
static NSString * const kMacroToTime                 = @"%%TO_TIME%%";
static NSString * const kMacroTimeCurrent            = @"%%TIME_CURRENT%%";
static NSString * const kMacroTimeStamp              = @"%%TIMESTAMP%%";
static NSString * const kMacroStreamId               = @"%%STREAM_ID%%";
static NSString * const kMacroSequenceId             = @"%%SEQUENCE_ID%%";
static NSString * const kMacroBallisticsCount        = @"%%COUNT%%";
static NSString * const kMacroShareDestination       = @"%%SHARE_DEST%%";
static NSString * const kMacroNotificationID         = @"%%NOTIF_ID%%";
static NSString * const kMacroSessionTime            = @"%%SESSION_TIME%%";

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
        _parameterMacroMapping = @{ VTrackingKeyFromTime           : kMacroFromTime,
                                    VTrackingKeyToTime             : kMacroToTime,
                                    VTrackingKeyTimeCurrent        : kMacroTimeCurrent,
                                    VTrackingKeyTimeStamp          : kMacroTimeStamp,
                                    VTrackingKeyStreamId           : kMacroStreamId,
                                    VTrackingKeySequenceId         : kMacroSequenceId,
                                    VTrackingKeyVoteCount          : kMacroBallisticsCount,
                                    VTrackingKeyShareDestination   : kMacroShareDestination,
                                    VTrackingKeyNotificationId     : kMacroNotificationID,
                                    VTrackingKeySessionTime        : kMacroSessionTime };
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
    
    dispatch_queue_t queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 );
    dispatch_async( queue, ^{
        [self sendRequest:request];
    });
    
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
    
    [macros enumerateKeysAndObjectsUsingBlock:^(NSString *macroKey, NSString *macroValue, BOOL *stop)
    {
        // For each macro, find a value in the parameters dictionary
        id paramValue = parameters[ macroKey ];
        NSString *stringWithNextMacro = [self stringFromString:output byReplacingString:macroValue withValue:paramValue ?: @""];
        if ( stringWithNextMacro != nil )
        {
            output = stringWithNextMacro;
        }
    }];
    
    while ( [output rangeOfString:kMacroBookendToken].location != NSNotFound )
    {
        NSRange startRange = [output rangeOfString:kMacroBookendToken];
        NSString *nextSegment = [output substringFromIndex:startRange.location + startRange.length];
        NSRange endRange = [nextSegment rangeOfString:kMacroBookendToken];
        NSRange totalRange = NSMakeRange( startRange.location, endRange.location + endRange.length + kMacroBookendToken.length );
        output = [output stringByReplacingCharactersInRange:totalRange withString:@""];
    }
    
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
    else if ( [value isKindOfClass:[NSString class]] )
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
    
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
    if ( connectionError )
    {
        VLog( @"Applicaiton Tracking :: ERROR with URL %@ :: %@", request.URL.absoluteString, [connectionError localizedDescription] );
    }
    else
    {
        VLog( @"Applicaiton Tracking :: SUCCESS with URL %@", request.URL.absoluteString );
    }
#endif
}

- (VTrackingURLRequest *)requestWithUrl:(NSString *)urlString objectManager:(VObjectManager *)objectManager
{
    NSParameterAssert( objectManager != nil );
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ( url == nil )
    {
#if DEBUG && APPLICATION_TRACKING_LOGGING_ENABLED
        VLog( @"Applicaiton Tracking :: ERROR :: Invalid URL %@.", urlString );
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

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    // Application tracking works by replacing macros in supplied URLs
    // If calling code doesn't supply any URLs, we can't proceed any further
    NSArray *urls = parameters[ VTrackingKeyUrls ];
    if ( urls != nil && urls.count > 0 )
    {
        [self trackEventWithUrls:urls andParameters:parameters];
    }
}

@end
