//
//  VFlurryTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFlurryTracking.h"
#import "Flurry.h"

#define FLURRY_TRACKING_LOGGING_ENABLED 0

#if DEBUG && FLURRY_TRACKING_LOGGING_ENABLED
#warning Tracking logging is enabled. Please remember to disable it when you're done debugging.
#endif

@interface VFlurryTracking()

@property (nonatomic, readonly) NSString *appVersionString;
@property (nonatomic, readonly) NSString *apiKey;

@end

@implementation VFlurryTracking

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSString *apiKey = self.apiKey;
        if ( apiKey )
        {
            NSString *appVersion = self.appVersionString;
            if ( appVersion )
            {
                // Call this before startSession:
                [Flurry setAppVersion:appVersion];
            }
            
            [Flurry startSession:apiKey];
            _enabled = YES;
        }
    }
    return self;
}

- (NSString *)appVersionString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", appVersion, buildNumber];
}

- (NSString *)apiKey
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"FlurryAPIKey"];
}

#pragma mark - VTrackingDelegate protocol

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    if ( !self.enabled )
    {
        return;
    }
    
    [Flurry logEvent:eventName withParameters:parameters];
    
#if DEBUG && FLURRY_TRACKING_LOGGING_ENABLED
    VLog( @"Flurry Tracking :: Event: %@", eventName );
#endif
}

@end
