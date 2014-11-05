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

static NSString * const kVFlurryAPIKey = @"YOUR_API_KEY";

@implementation VFlurryTracking

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [Flurry startSession:kVFlurryAPIKey];
    }
    return self;
}

#pragma mark - VTrackingDelegate protocol

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
{
    [Flurry logEvent:eventName withParameters:parameters];
    
#if DEBUG && FLURRY_TRACKING_LOGGING_ENABLED
    VLog( @"Flurry Tracking :: Event: %@", eventName );
#endif
}

@end
