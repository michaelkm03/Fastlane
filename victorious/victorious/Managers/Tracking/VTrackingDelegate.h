//
//  VTrackingDelegate.h
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Required protocol for tracking services to be added to VTrackingManager.
 */
@protocol VTrackingDelegate <NSObject>

- (void)trackEventWithName:(NSString *)eventName parameters:(NSDictionary *)parameters;

@optional

- (void)eventStarted:(NSString *)eventName parameters:(NSDictionary *)parameters;

- (void)eventEnded:(NSString *)eventName parameters:(NSDictionary *)parameters duration:(NSTimeInterval)duration;

@end
