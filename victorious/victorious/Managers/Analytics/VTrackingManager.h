//
//  VTrackingManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VTracking.h"
#import "VAnalyticsConstants.h"

@interface VTrackingManager : NSObject

- (NSInteger)trackEventWithUrls:(NSArray *)urls andParameters:(NSDictionary *)parameters;

@end
