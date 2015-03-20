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
#import "VURLMacroReplacement.h"
#import "NSCharacterSet+VURLParts.h"

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
static NSString * const kMacroLoadTime               = @"%%LOAD_TIME%%";

#define APPLICATION_TRACKING_LOGGING_ENABLED 0

#if APPLICATION_TRACKING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VApplicationTracking()

@property (nonatomic, readonly) NSDictionary *parameterMacroMapping;
@property (nonatomic, strong) VURLMacroReplacement *macroReplacement;

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
                                    VTrackingKeySessionTime        : kMacroSessionTime,
                                    VTrackingKeyLoadTime           : kMacroLoadTime };
        _macroReplacement = [[VURLMacroReplacement alloc] init];
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
                                        withCorrespondingParameters:parameters];
    if ( !urlWithMacrosReplaced )
    {
        return NO;
    }
    
    
    VObjectManager *objManager = [self applicationObjectManager];
    
    NSURLComponents *URLCompontents = [NSURLComponents componentsWithString:urlWithMacrosReplaced];
    URLCompontents.path = [URLCompontents.path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
    NSString *escapedURLWithMacrosReplace = [URLCompontents string];
    VTrackingURLRequest *request = [self requestWithUrl:escapedURLWithMacrosReplace objectManager:objManager];
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

- (NSString *)stringByReplacingMacros:(NSDictionary *)macros inString:(NSString *)originalString withCorrespondingParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *replacementsDictionary = [[NSMutableDictionary alloc] initWithCapacity:parameters.count];
    for (NSString *parameter in parameters.keyEnumerator)
    {
        NSString *macro = self.parameterMacroMapping[parameter];
        if ( macro != nil )
        {
            replacementsDictionary[macro] = [self stringFromParameterValue:parameters[parameter]];
        }
    }
    
    return [self.macroReplacement urlByReplacingMacrosFromDictionary:replacementsDictionary inURLString:originalString];
}

- (NSString *)stringFromParameterValue:(id)value
{
    NSString *stringValue = nil;
    
    if ( [value isKindOfClass:[NSDate class]] )
    {
        stringValue = [self.dateFormatter stringFromDate:(NSDate *)value];
    }
    else if ( [value isKindOfClass:[NSNumber class]] )
    {
        if ( CFNumberIsFloatType( (CFNumberRef)value ) )
        {
            stringValue = [NSString stringWithFormat:@"%.2f", ((NSNumber *)value).floatValue];
        }
        else
        {
            stringValue = [NSString stringWithFormat:@"%i", ((NSNumber *)value).intValue];
        }
    }
    else if ( [value isKindOfClass:[NSString class]] )
    {
        stringValue = value;
    }
    
    if ( !stringValue )
    {
        return nil;
    }
    
    return stringValue;
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
    
#if APPLICATION_TRACKING_LOGGING_ENABLED
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
#if APPLICATION_TRACKING_LOGGING_ENABLED
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
