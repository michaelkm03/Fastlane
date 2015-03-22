//
//  VBadgeStringFormatter.m
//  victorious
//
//  Created by Michael Sena on 3/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBadgeStringFormatter.h"

static NSInteger const kLargeNumberCutoff = 100; ///< Numbers equal to or greater than this cutoff will not display

@implementation VBadgeStringFormatter

+ (NSString *)formattedBadgeStringForBadgeNumber:(NSInteger)badgeNumber
{
    if (badgeNumber == 0)
    {
        return @"";
    }
    else if (badgeNumber < kLargeNumberCutoff)
    {
        return [NSString stringWithFormat:@"%ld", (long)badgeNumber];
    }
    else
    {
        return [NSString stringWithFormat:NSLocalizedString(@"%ld+", @"Number and symbol meaning \"more than\", e.g. \"99+ items\". (%ld is a placeholder for a number)"), (long)(kLargeNumberCutoff - 1)];
    }
}

@end
