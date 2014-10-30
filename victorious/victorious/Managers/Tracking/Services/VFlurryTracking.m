//
//  VFlurryTracking.m
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFlurryTracking.h"
#import "Flurry.h"

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

#pragma mark - VTrackingService protocol

- (void)trackEventWithName:(NSString *)eventName withParameters:(NSDictionary *)parameters
{
    [Flurry logEvent:eventName withParameters:parameters];
    
    // [Flurry endTimedEvent:@"Article_Read" withParameters:nil];
    
    /*[Flurry setAge:21];
    
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
