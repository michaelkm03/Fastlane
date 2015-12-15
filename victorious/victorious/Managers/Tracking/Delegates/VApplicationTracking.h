//
//  VApplicationTracking.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VTracking.h"
#import "VTrackingDelegate.h"

@class VDependencyManager;
@protocol TrackingRequestScheduler;

@interface VApplicationTracking : NSObject <VTrackingDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) id<TrackingRequestScheduler> requestScheduler;

/**
 An array of event names as NSStrings for which network requests for trackings calls will be
 executed immediately and not scheduled for later execution.  This is required for some events
 that are critical to measuring session activity.
 */
@property (nonatomic, strong) NSArray<NSString *> *immediateExecutionWhiteList;

@end
