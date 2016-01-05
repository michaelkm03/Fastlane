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
#import "VEventTracker.h"

/**
 A singleton object that provides tracking functionality according to the interface
 of the `VEventTracker` protocol.
 */
@interface VTrackingManager : NSObject <VEventTracker>

+ (VTrackingManager *)sharedInstance;

@end
