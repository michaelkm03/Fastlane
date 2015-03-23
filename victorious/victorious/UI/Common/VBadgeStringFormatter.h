//
//  VBadgeStringFormatter.h
//  victorious
//
//  Created by Michael Sena on 3/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBadgeStringFormatter : NSObject

/**
 *  Formats an integer for presentation in a badge label. 
 *  Uses a cutoff number after which numbers are simply XX+
 *
 *  Returns an empty string if badgeNumber is equal to 0.
 *
 *  @param badgeNumber The integer to 
 *
 *  @return The formatted string.
 */
+ (NSString *)formattedBadgeStringForBadgeNumber:(NSInteger)badgeNumber;

@end
