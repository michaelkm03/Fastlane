//
//  VTrackingService.h
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Required protocol for tracking services to be added to VTrackingManager.
 */
@protocol VTrackingService <NSObject>

- (void)trackEventWithName:(NSString *)eventName withParameters:(NSDictionary *)parameters;

@end