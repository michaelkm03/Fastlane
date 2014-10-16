//
//  VAnalyticsConstants.h
//  victorious
//
//  Created by Patrick Lynch on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kAnalyticsEventVideoStart           = @"view-start";
static NSString * const kAnalyticsEventVideoComplete25      = @"view-25-complete";
static NSString * const kAnalyticsEventVideoComplete50      = @"view-50-complete";
static NSString * const kAnalyticsEventVideoComplete75      = @"view-75-complete";
static NSString * const kAnalyticsEventVideoComplete100     = @"view-100-complete";
static NSString * const kAnalyticsEventVideoError           = @"view-error";
static NSString * const kAnalyticsEventVideoStall           = @"view-stall";
static NSString * const kAnalyticsEventVideoSkip            = @"view-skip";
static NSString * const kAnalyticsEventSequenceCellView     = @"cell-view";
static NSString * const kAnalyticsEventSequenceCellClick    = @"cell-click";

static NSString * const kAnalyticsKeyTimeFrom               = @"%%FROM_TIME%%";
static NSString * const kAnalyticsKeyTimeTo                 = @"%%TO_TIME%%";
static NSString * const kAnalyticsKeyUserTime               = @"%%TIME%%";
static NSString * const kAnalyticsKeyPageLAbel              = @"%%PAGE%%";
static NSString * const kAnalyticsKeyStreamName             = @"%%STREAM%%";
static NSString * const kAnalyticsKeyPositionX              = @"%%XPOS%%";
static NSString * const kAnalyticsKeyPositionY              = @"%%YPOS%%";
static NSString * const kAnalyticsKeyNavigiationFrom        = @"%%NAV_FROM%%";
static NSString * const kAnalyticsKeyNavigiationTo          = @"%%NAV_TO%%";
