//
//  VFlurryTracking.h
//  victorious
//
//  Created by Patrick Lynch on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTrackingDelegate.h"

@import CoreLocation;

@interface VFlurryTracking : NSObject <VTrackingDelegate, CLLocationManagerDelegate>

@end
