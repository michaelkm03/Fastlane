//
//  VApplicationTracking.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import VictoriousIOSSDK;

#import <Foundation/Foundation.h>
#import "VTracking.h"
#import "VTrackingDelegate.h"

@class VDependencyManager;
@class TrackingRequestScheduler;

@interface VApplicationTracking : NSObject <VTrackingDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong, readonly) TrackingRequestScheduler *requestScheduler;

/**
 Tracks event using URLS after replacing URL-embedded macros with values
 that correspond to values in parameters dictionary.  That is to say, the keys in 
 the parameters dictionary should be the same as the macro in the URLs that the value
 for that key is intended to replace.  See VTrackingConstants for list of supported keys/macros.
 */
- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters;

@end
