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
 [[VTrackingManager sharedInstance] trackEventWithName:@"my_event_name" parameters:params];
 
 In your service:
 - (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters
 {
    if ( eventName isEqualToString:@"my_event_name"] )
    {
        // Handle event using parameters dictionary
    }
 }
 */
@interface VTrackingManager : NSObject

/**
 If the current session was started in response to a
 notification, the notification ID should be set in
 this property. It will be added to tracking calls
 that include the notification ID macro.
 */
@property (nonatomic, strong) NSString *notificationID;

+ (VTrackingManager *)sharedInstance;

/**
 Forwards a tracking event to any added VTrackingDelegate instanced.
 */
- (void)trackEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

/**
 Captures an event to be sent later or prevent another event from being sent.
 @param eventId An ID to test the event's uniqueness to prevent duplicates in the queue.
 @param groupId An ID to separate events into groups so that they can be dequeued in batches.
 */
- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *)parameters eventId:(id)eventId;

/**
 Removes events from queue and tracks thems using trackEvent:parameters
 */
- (void)clearQueuedEventsWithName:(NSString *)eventName;

- (void)startEvent:(NSString *)eventName;

- (void)startEvent:(NSString *)evetName parameters:(NSDictionary *)parameters;

- (void)endEvent:(NSString *)eventName;

- (void)trackEvent:(NSString *)eventName;

- (void)addDelegate:(id<VTrackingDelegate>)service;

- (void)removeDelegate:(id<VTrackingDelegate>)service;

- (void)removeAllDelegates;

@end
