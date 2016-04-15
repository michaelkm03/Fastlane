//
//  NSDate+timeSince.h
//  victorious
//
//  Created by Gary Philipp on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VTimeSincePrecision) {
    VTimeSincePrecisionMinutes, //< Default
    VTimeSincePrecisionSeconds
};

@interface NSDate (timeSince)

- (NSString *)stringDescribingTimeIntervalSinceNowWithPrecision:(VTimeSincePrecision)precision;
- (NSString *)stringDescribingTimeIntervalSince:(NSDate *)date precision:(VTimeSincePrecision)precision;

- (NSString *)stringDescribingTimeIntervalSinceNow;
- (NSString *)stringDescribingTimeIntervalSince:(NSDate *)date;

@end
