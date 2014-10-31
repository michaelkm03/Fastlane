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
        
        //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        //locationManager.delegate = self;
        //[locationManager startUpdatingLocation];
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
    
    // [Flurry endTimedEvent:@"Article_Read" parameters:nil];
    
    /*
    // Here's more stuff you can do with Flurry, copied from the documentation
     
    [Flurry setAge:21];
    
    [Flurry setGender:@"m"];
    
    [Flurry setUserID:@"USER_ID"];
    
    [Flurry logError:@"ERROR_NAME" message:@"ERROR_MESSAGE" exception:e];
    
    [Flurry logAllPageViews:navigationController];
    
    [Flurry logPageView];
    
    [Flurry setSessionReportsOnCloseEnabled:(BOOL)sendSessionReportsOnClose];
        
    [Flurry setSessionReportsOnPauseEnabled:(BOOL)sendSessionReportsOnPause];
    
    [Flurry setSecureTransportEnabled:(BOOL)secureTransport];*/
}

#pragma mark - 

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = locations.firstObject;
    [Flurry setLatitude:newLocation.coordinate.latitude
              longitude:newLocation.coordinate.longitude
     horizontalAccuracy:newLocation.horizontalAccuracy
       verticalAccuracy:newLocation.verticalAccuracy];
}

@end
