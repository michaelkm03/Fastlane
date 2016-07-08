//
//  VEventTracker.h
//  victorious
//
//  Created by Patrick Lynch on 12/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an object that can perform some basic tracking functions.
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
@protocol VEventTracker <NSObject>

#pragma mark - Event Tracking

/**
 Forwards a tracking event to any added VTrackingDelegate instanced.
 */
- (void)trackEvent:(NSString *_Nullable)eventName parameters:(NSDictionary *_Nullable)parameters sessionParameters:(NSDictionary *_Nullable)sessionParameters;

- (void)trackEvent:(NSString *_Nullable)eventName parameters:(NSDictionary *_Nullable)parameters;

- (void)trackEvent:(NSString *_Nullable)eventName;

@optional

/**
 Captures an event to be sent later or prevent another event from being sent.
 @param eventName An ID to separate events into groups so that they can be dequeued in batches.
 @param parameters Additional fields describing the tracking event. Keys from VTrackingConstants
 are used to utilize fields from this dictionary.
 @param eventId An ID to test the event's uniqueness to prevent duplicates in the queue.
 */
- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *_Nullable)parameters eventId:(NSString *)eventId;

- (void)queueEvent:(NSString *)eventName parameters:(NSDictionary *)parameters eventId:(NSString *)eventId sessionParameters:(NSDictionary *)sessionParameters;

/**
 Removes events from queue and tracks thems using trackEvent:parameters
 */
- (void)clearQueuedEventsWithName:(NSString *)eventName;

#pragma mark - Session Values

/**
 Adds a new parameter that will be passed to all tracking calls until cleared.
 */
- (void)setValue:(id _Nullable)value forSessionParameterWithKey:(NSString *)key;

/**
 Clears a session parameter if it existied, otherwise does nothing.
 */
- (void)clearValueForSessionParameterWithKey:(NSString *)key;

/**
 Clears all session properties
 */
- (void)clearAllSessionParameterValues;

#pragma mark - Delegates

- (void)addDelegate:(id<VTrackingDelegate>)service;

- (void)removeDelegate:(id<VTrackingDelegate>)service;

- (void)removeAllDelegates;

#pragma mark - Timing

- (void)startEvent:(NSString *)eventName;

- (void)startEvent:(NSString *)evetName parameters:(NSDictionary *)parameters;

- (void)endEvent:(NSString *)eventName;

#pragma mark - Debug

/**
  ** NON-PRODUCTION BUILDS ONLY **
 Shows alerts track events sent with `trackEvent:parameters:` method.
 */
@property (nonatomic, assign) BOOL showTrackingEventAlerts;

/**
 ** NON-PRODUCTION BUILDS ONLY **
 Shows alerts track events sent with `startEvent:parameters:` and `endEvent:` methods.
 */
@property (nonatomic, assign) BOOL showTrackingStartEndAlerts;

@end

NS_ASSUME_NONNULL_END
