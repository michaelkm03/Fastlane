//
//  VTrackingManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTrackingDelegate.h"
#import "VTrackingConstants.h"

/**
 Receives and dispenses tracking events to any added services that conform to VTrackingDelegate.
 
 Adding a service:
 MyTrackingService* service = [[MyTrackingService alloc] init];
 [VTrackingManager addDelegate:service];
 
 Tracking an event:
 NSDictionary *params = { ... };
 [[VTrackingManager sharedInstance] trackEventWithName:@"my_event_name" withParameters:params];
 
 In your service:
 - (void)trackEventWithName:(NSString *)eventName withParameters:(NSDictionary *)parameters
 {
    if ( eventName isEqualToString:@"my_event_name"] )
    {
        // Handle event using parameters dictionary
    }
 }
 */
@interface VTrackingManager : NSObject

+ (VTrackingManager *)sharedInstance;

- (void)trackEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

- (void)trackEvent:(NSString *)eventName;

- (void)addDelegate:(id<VTrackingDelegate>)service;

- (void)removeService:(id<VTrackingDelegate>)service;

- (void)removeAllServices;

@end
