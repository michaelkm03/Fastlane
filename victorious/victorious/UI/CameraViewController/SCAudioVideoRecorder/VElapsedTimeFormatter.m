//
//  VElapsedTimeFormatter.m
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VElapsedTimeFormatter.h"

@implementation VElapsedTimeFormatter

- (NSString *)stringForCMTime:(CMTime)time
{
    NSString *separator = NSLocalizedString(@"TimeSeparator", @"");
    
    if (CMTIME_IS_VALID(time))
    {
        Float64 seconds = CMTimeGetSeconds(CMTimeAbsoluteValue(time));
        Float64 minutes = floor(seconds / 60.0);
        seconds -= minutes * 60.0;
        if (minutes >= 60.0)
        {
            Float64 hours = floor(minutes / 60.0);
            minutes -= hours * 60.0;
            return [NSString stringWithFormat:@"%.0f%@%02.0f%@%02.0f", hours, separator, minutes, separator, round(seconds)];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f%@%02.0f", minutes, separator, round(seconds)];
        }
    }
    else
    {
        return NSLocalizedString(@"InvalidTimePlaceholder", @"");
    }
}

@end
