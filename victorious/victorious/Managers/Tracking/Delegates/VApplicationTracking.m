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
#import "VSDKURLMacroReplacement.h"
#import "NSCharacterSet+VURLParts.h"
#import "VDependencyManager+VTracking.h"
#import "VSessionTimer.h"
#import "VRootViewController.h"
#import "victorious-Swift.h"

static NSString * const kMacroFromTime               = @"%%FROM_TIME%%";
static NSString * const kMacroToTime                 = @"%%TO_TIME%%";
static NSString * const kMacroTimeCurrent            = @"%%TIME_CURRENT%%";
static NSString * const kMacroTimeStamp              = @"%%TIMESTAMP%%";
static NSString * const kMacroStreamId               = @"%%STREAM_ID%%";
static NSString * const kMacroSequenceId             = @"%%SEQUENCE_ID%%";
static NSString * const kMacroBallisticsCount        = @"%%COUNT%%";
static NSString * const kMacroShareDestination       = @"%%SHARE_DEST%%";
static NSString * const kMacroSharedToFacebook       = @"%%FACEBOOK_SHARE%%";
static NSString * const kMacroSharedToTwitter        = @"%%TWITTER_SHARE%%";
static NSString * const kMacroNotificationID         = @"%%NOTIF_ID%%";
static NSString * const kMacroSessionTime            = @"%%SESSION_TIME%%";
static NSString * const kMacroLoadTime               = @"%%LOAD_TIME%%";
static NSString * const kMacroPermissionState        = @"%%PERMISSION_STATE%%";
static NSString * const kMacroPermissionName         = @"%%PERMISSION_NAME%%";
static NSString * const kMacroAutoplay               = @"%%IS_AUTOPLAY%%";
static NSString * const kMacroConnectivity           = @"%%CONNECTIVITY%%";
static NSString * const kMacroVolumeLevel            = @"%%VOLUME_LEVEL%%";
static NSString * const kMacroErrorType              = @"%%ERROR_TYPE%%";
static NSString * const kMacroErrorDetails           = @"%%ERROR_DETAILS%%";

#define APPLICATION_TRACKING_LOGGING_ENABLED 0
#define APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED 0

#if APPLICATION_TRACKING_LOGGING_ENABLED || APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VApplicationTracking()

@property (nonatomic, readonly) NSDictionary *parameterMacroMapping;
@property (nonatomic, readonly) NSDictionary *keyForEventMapping;
@property (nonatomic, strong) VSDKURLMacroReplacement *macroReplacement;
@property (nonatomic, strong, readwrite) TrackingRequestScheduler *requestScheduler;

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
                                    VTrackingKeySharedToFacebook   : kMacroSharedToFacebook,
                                    VTrackingKeySharedToTwitter    : kMacroSharedToTwitter,
                                    VTrackingKeyNotificationId     : kMacroNotificationID,
                                    VTrackingKeySessionTime        : kMacroSessionTime,
                                    VTrackingKeyLoadTime           : kMacroLoadTime,
                                    VTrackingKeyPermissionName     : kMacroPermissionName,
                                    VTrackingKeyPermissionState    : kMacroPermissionState,
                                    VTrackingKeyAutoplay           : kMacroAutoplay,
                                    VTrackingKeyConnectivity       : kMacroConnectivity,
                                    VTrackingKeyVolumeLevel        : kMacroVolumeLevel,
                                    VTrackingKeyErrorType          : kMacroErrorType,
                                    VTrackingKeyErrorDetails       : kMacroErrorDetails };
        
        _keyForEventMapping = @{ VTrackingEventUserDidStartCreateProfile           : VTrackingCreateProfileStartKey,
                                 VTrackingEventUserDidStartRegistration            : VTrackingRegistrationStartKey,
                                 VTrackingEventUserDidFinishRegistration           : VTrackingRegistrationEndKey,
                                 VTrackingEventUserDidSelectRegistrationDone       : VTrackingCreateProfileDoneButtonTapKey,
                                 VTrackingEventUserDidSelectRegistrationOption     : VTrackingRegisteButtonTapKey,
                                 VTrackingEventUserDidSelectSignUpSubmit           : VTrackingSignUpButtonTapKey,
                                 VTrackingEventUserPermissionDidChange             : VTrackingPermissionChangeKey,
                                 VTrackingEventLoginWithFacebookDidFail            : VTrackingAppErrorKey };
        
        _macroReplacement = [[VSDKURLMacroReplacement alloc] init];
        _requestScheduler = [[TrackingRequestScheduler alloc] init];
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
    
    NSMutableDictionary *completeParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    VSessionTimer *sessionTimer = [VRootViewController rootViewController].sessionTimer;
    completeParameters[ VTrackingKeySessionTime ] = @(sessionTimer.sessionDuration);
    
    NSString *urlWithMacrosReplaced = [self stringByReplacingMacros:self.parameterMacroMapping
                                                           inString:url
                                        withCorrespondingParameters:completeParameters.copy];
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
    
    [self.requestScheduler scheduleRequest:request];
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
        NSLog( @"Application Tracking :: ERROR with URL %@ :: %@", request.URL.absoluteString, [connectionError localizedDescription] );
    }
    else
    {
        NSLog( @"Application Tracking :: SUCCESS with URL %@", request.URL.absoluteString );
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
        NSLog( @"Application Tracking :: ERROR :: Invalid URL %@.", urlString );
#endif
        return nil;
    }
    
    VTrackingURLRequest *request = [VTrackingURLRequest requestWithURL:url];
    [objectManager updateHTTPHeadersInRequest:request];
    request.HTTPBody = nil;
    request.HTTPMethod = @"GET";
    return request;
}

// Adds template-driven tracking URLs that are not context-specific and read from dependency manager
- (NSArray *)templateURLsWithEventName:(NSString *)eventName eventParameters:(NSDictionary *)eventParams
{
    if ( self.dependencyManager == nil )
    {
#if APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED
        NSLog( @"A dependency manager instance must be set before events can be properly tracked." );
#endif
        return nil;
    }
    
    NSString *key = self.keyForEventMapping[ eventName ];
    NSArray *urls = [self.dependencyManager trackingURLsForKey:key];
    
#if APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED
    if ( urls.count > 0 )
    {
        NSLog( @"Application Tracking :: Adding Template URLS to event: %@\n%@.", eventName, urls );
    }
#endif
    
    return urls;
}

#pragma mark - VTrackingDelegate

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    NSArray *templateURLs = [self templateURLsWithEventName:eventName eventParameters:parameters];
    NSArray *eventURLs = parameters[ VTrackingKeyUrls ];
    NSArray *allURLs = [eventURLs ?: @[] arrayByAddingObjectsFromArray:templateURLs];
    
    // Application tracking works by replacing macros in supplied URLs
    // If calling code doesn't supply any URLs, we can't proceed any further
    if ( allURLs != nil && allURLs.count > 0 )
    {
        [self trackEventWithUrls:allURLs andParameters:parameters];
    }
}

@end
