//
//  NSString+RFC2822Date.m
//  victorious
//
//  Created by Michael Sena on 9/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSString+RFC2822Date.h"

@implementation NSString (RFC2822Date)

+ (NSString *)stringForRFC2822Date:(NSDate *)date
{
    static NSDateFormatter *sRFC2822DateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRFC2822DateFormatter = [[NSDateFormatter alloc] init];
        sRFC2822DateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
        
        [sRFC2822DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    });
    
    return [sRFC2822DateFormatter stringFromDate:date];
}

@end
