//
//  VTrackingEventLog.h
//  victorious
//
//  Created by Patrick Lynch on 3/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTrackingEventLog : NSObject

extern NSString * const VTrackingEventLogKeyEventName;
extern NSString * const VTrackingEventLogKeyDate;

@property (nonatomic, readonly) NSArray *events;

- (void)logEvent:(NSString *)eventName parameters:(NSDictionary *)parameters;

- (void)clearEvents;

@end
