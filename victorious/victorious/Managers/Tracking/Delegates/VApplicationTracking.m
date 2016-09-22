//
//  VApplicationTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VApplicationTracking.h"
#import "VDependencyManager+VTracking.h"
#import "VSessionTimer.h"
#import "VRootViewController.h"
#import "victorious-Swift.h"

@import VictoriousCommon;
@import VictoriousIOSSDK;

static NSString * const kMacroContentId              = @"%%CONTENT_ID%%";
static NSString * const kMacroContext                = @"%%CONTEXT%%";
static NSString * const kMacroParentContentId        = @"%%PARENT_CONTENT_ID%%";
static NSString * const kMacroFromTime               = @"%%FROM_TIME%%";
static NSString * const kMacroToTime                 = @"%%TO_TIME%%";
static NSString * const kMacroTimeCurrent            = @"%%TIME_CURRENT%%";
static NSString * const kMacroTimeStamp              = @"%%TIMESTAMP%%";
static NSString * const kMacroStreamId               = @"%%STREAM_ID%%";
static NSString * const kMacroSequenceId             = @"%%SEQUENCE_ID%%";
static NSString * const kMacroBallisticsCount        = @"%%COUNT%%";
static NSString * const kMacroShareDestination       = @"%%SHARE_DEST%%";
static NSString * const kMacroSharedToFacebook       = @"%%FACEBOOK_SHARE%%";
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
static NSString * const kMacroDuration               = @"%%DURATION%%";
static NSString * const kMacroType                   = @"%%TYPE%%";
static NSString * const kMacroSubtype                = @"%%SUBTYPE%%";
static NSString * const kMacroProfileContext         = @"%%PROFILE_CONTEXT%%";

#define APPLICATION_TRACKING_LOGGING_ENABLED 0
#define APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED 0

#if APPLICATION_TRACKING_LOGGING_ENABLED || APPLICATION_TEMPLATE_MAPPING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VApplicationTracking() <VSessionTimerDelegate>

@property (nonatomic, readonly) NSDictionary *parameterMacroMapping;
@property (nonatomic, readonly) NSDictionary *keyForEventMapping;
@property (nonatomic, strong) VSDKURLMacroReplacement *macroReplacement;
@property (nonatomic, assign) NSUInteger requestCounter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation VApplicationTracking

#pragma mark - Init and dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // This is a mapping of generic parameters to application-specific macros
        _parameterMacroMapping = @{
                                    VTrackingKeyContentId          : kMacroContentId,
                                    VTrackingKeyContext            : kMacroContext,
                                    VTrackingKeyParentContentId    : kMacroParentContentId,
                                    VTrackingKeyFromTime           : kMacroFromTime,
                                    VTrackingKeyToTime             : kMacroToTime,
                                    VTrackingKeyTimeCurrent        : kMacroTimeCurrent,
                                    VTrackingKeyTimeStamp          : kMacroTimeStamp,
                                    VTrackingKeyStreamId           : kMacroStreamId,
                                    VTrackingKeySequenceId         : kMacroSequenceId,
                                    VTrackingKeyVoteCount          : kMacroBallisticsCount,
                                    VTrackingKeyShareDestination   : kMacroShareDestination,
                                    VTrackingKeySharedToFacebook   : kMacroSharedToFacebook,
                                    VTrackingKeyNotificationId     : kMacroNotificationID,
                                    VTrackingKeySessionTime        : kMacroSessionTime,
                                    VTrackingKeyLoadTime           : kMacroLoadTime,
                                    VTrackingKeyPermissionName     : kMacroPermissionName,
                                    VTrackingKeyPermissionState    : kMacroPermissionState,
                                    VTrackingKeyAutoplay           : kMacroAutoplay,
                                    VTrackingKeyConnectivity       : kMacroConnectivity,
                                    VTrackingKeyVolumeLevel        : kMacroVolumeLevel,
                                    VTrackingKeyErrorType          : kMacroErrorType,
                                    VTrackingKeyErrorDetails       : kMacroErrorDetails,
                                    VTrackingKeyType               : kMacroType,
                                    VTrackingKeySubtype            : kMacroSubtype,
                                    VTrackingKeyDuration           : kMacroDuration };
        
        _keyForEventMapping = @{ VTrackingEventUserDidStartCreateProfile           : VTrackingCreateProfileStartKey,
                                 VTrackingEventUserDidStartRegistration            : VTrackingRegistrationStartKey,
                                 VTrackingEventUserDidFinishRegistration           : VTrackingRegistrationEndKey,
                                 VTrackingEventUserDidSelectRegistrationDone       : VTrackingCreateProfileDoneButtonTapKey,
                                 VTrackingEventUserDidSelectRegistrationOption     : VTrackingRegisteButtonTapKey,
                                 VTrackingEventUserDidSelectSignUpSubmit           : VTrackingSignUpButtonTapKey,
                                 VTrackingEventUserPermissionDidChange             : VTrackingPermissionChangeKey,
                                 VTrackingEventLoginWithFacebookDidFail            : VTrackingAppErrorKey,
                                 VTrackingEventSentPurchaseRequestToStore          : VTrackingEventSentPurchaseRequestToStore,
                                 VTrackingEventSentProductReceiptToBackend         : VTrackingEventSentProductReceiptToBackend,
                                 VTrackingEventRecievedPurchaseCompletionFromStore : VTrackingEventRecievedPurchaseCompletionFromStore,
                                 VTrackingEventRecievedProductReceiptFromBackend   : VTrackingEventRecievedProductReceiptFromBackend };
        
        _macroReplacement = [[VSDKURLMacroReplacement alloc] init];
        _requestCounter = NSUIntegerMax;
        _dateFormatter = [NSDateFormatter vsdk_defaultDateFormatter];
    }
    return self;
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

- (BOOL)validateURL:(NSString *)url
{
    return url != nil && [url isKindOfClass:[NSString class]] && url.length > 0;
}

- (BOOL)trackEventWithUrl:(NSString *)url andParameters:(NSDictionary *)parameters
{
    if ( ![self validateURL:url] )
    {
        return NO;
    }
    
    NSURL *requestURL = [self urlByReplacingMacrosInURL:url withParameters:parameters];

    if ( requestURL == nil )
    {
        return NO;
    }
    
    [self sendRequest:requestURL eventIndex:[self orderOfNextRequest] completion:^(NSError *error)
    {
#if APPLICATION_TRACKING_LOGGING_ENABLED
        if ( error )
        {
            NSLog( @"Application Tracking :: ERROR with URL %@ :: %@", requestURL.absoluteString, [error localizedDescription] );
        }
        else
        {
            NSLog( @"Application Tracking :: SUCCESS with URL %@", requestURL.absoluteString );
        }
#endif
    }];
    return YES;
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

- (nullable NSURL *)urlByReplacingMacrosInURL:(NSString *)urlString withParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *completeParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    VSessionTimer *sessionTimer = [VRootViewController sharedRootViewController].sessionTimer;
    
    completeParameters[ VTrackingKeySessionTime ] = @(sessionTimer.sessionDuration);
    
    NSMutableDictionary *replacementsDictionary = [[NSMutableDictionary alloc] initWithCapacity:completeParameters.count];
    for (NSString *parameter in completeParameters.keyEnumerator)
    {
        NSString *macro = self.parameterMacroMapping[parameter];
        if ( macro != nil )
        {
            replacementsDictionary[macro] = [self stringFromParameterValue:completeParameters[parameter]];
        }
    }
    NSString *urlWithMacrosReplaced = [self.macroReplacement urlByReplacingMacrosFromDictionary:replacementsDictionary inURLString:urlString];
    NSURL *url = [NSURL URLWithString:urlWithMacrosReplaced];
    
#if APPLICATION_TRACKING_LOGGING_ENABLED
    if ( url == nil )
    {
        NSLog( @"Application Tracking :: ERROR :: Invalid URL %@.", urlString );
    }
#endif
    
    return url;
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

#pragma mark - VSessionTimerDelegate

- (void)sessionTimerDidResetSession:(VSessionTimer *)sessionTimer
{
    self.requestCounter = 0;
}

#pragma mark -

- (NSUInteger)orderOfNextRequest
{
    if ( self.requestCounter >= NSUIntegerMax )
    {
        self.requestCounter = 0;
    }
    return ++self.requestCounter;
}

@end
