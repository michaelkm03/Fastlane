//
//  VTrackingQueue.h
//  victorious
//
//  Created by Patrick Lynch on 10/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTrackingQueue : NSObject

/**
 Queues a tracking event call in memory to be sent later.
 */
- (BOOL)queueEventWithName:(NSString *)eventName andParameters:(NSDictionary *)parameters withKey:(id)key;

@property (nonatomic, readonly) NSUInteger numberOfQueuedEvents;

@property (nonatomic, readonly) NSMutableArray *events;

@end