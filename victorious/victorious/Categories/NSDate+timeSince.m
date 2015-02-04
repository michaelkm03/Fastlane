//
//  NSDate+timeSince.m
//  victorious
//
//  Created by Gary Philipp on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSDate+timeSince.h"

@implementation NSDate (timeSince)

- (NSString *)timeSince
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now =   [NSDate date];
    NSDateComponents *components = [calendar components:
                                    NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitWeekOfMonth|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitMinute|
                                    NSCalendarUnitSecond
                                               fromDate:self
                                                 toDate:now
                                                options:0];
    
    if (components.year >= 1)
    {
        if (components.year == 1)
        {
            return NSLocalizedString(@"LastYear", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"YearsAgo", @""), components.year];
        }
    }
    else if (components.month >= 1)
    {
        if (components.month == 1)
        {
            return NSLocalizedString(@"LastMonth", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"MonthsAgo", @""), components.month];
        }
    }
    else if (components.weekOfMonth >= 1)
    {
        if (components.weekOfMonth == 1)
        {
            return NSLocalizedString(@"LastWeek", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"WeeksAgo", @""), components.weekOfMonth];
        }
    }
    else if (components.day >= 1)    // up to 6 days ago
    {
        if (components.day == 1)
        {
            return NSLocalizedString(@"Yesterday", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"DaysAgo", @""), components.day];
        }
    }
    else if (components.hour >= 1)   // up to 23 hours ago
    {
        if (components.hour == 1)
        {
            return NSLocalizedString(@"HourAgo", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"HoursAgo", @""), components.hour];
        }
    }
    else if (components.minute >= 1) // up to 59 minutes ago
    {
        if (components.minute == 1)
        {
            return NSLocalizedString(@"MinuteAgo", @"");
        }
        else
        {
            return [NSString stringWithFormat:NSLocalizedString(@"MinutesAgo", @""), components.minute];
        }
    }
    else
    {
        return NSLocalizedString(@"Now", @"");
    }
}

@end
