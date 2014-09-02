//
//  VLargeNumberFormatter.h
//  victorious
//
//  Created by Josh Hinman on 6/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A formatter for displaying large numbers in a compact format (e.g. 2k, 30M, etc)
 */
@interface VLargeNumberFormatter : NSObject

/**
 Returns a string describing the value of the time argument
 */
- (NSString *)stringForInteger:(NSInteger)integer;

@end
