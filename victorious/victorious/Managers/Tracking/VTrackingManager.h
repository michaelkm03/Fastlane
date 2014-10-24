//
//  VTrackingManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VTracking.h"
#import "VTrackingConstants.h"
#import "VTrackingEvent.h"

@interface VTrackingManager : NSObject

/**
 Tracks event using URLS after replacing URL-embedded macros with values
 that correspond to values in parameters dictionary.  That is to say, the keys in 
 the parameters dictionary should be the same as the macro in the URLs that the value
 for that key is intended to replace.  See VTrackingConstants for list of supported keys/macros.
 */
- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters;

/**
 Queues a tracking event call in memory to be sent later.
 */
- (BOOL)queueEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters withKey:(id)key;

/**
 Sends tracking calls for all events stored in its internal queue.
 */
- (void)sendQueuedTrackingEvents;

/**
 Determines if any queued tracking envets should be sent when this object is destroyed.
 If set to YES, events will not be sent and will be lost.
 */
@property (nonatomic, assign) BOOL shouldIgnoreEventsInQueueOnDealloc;

@end
