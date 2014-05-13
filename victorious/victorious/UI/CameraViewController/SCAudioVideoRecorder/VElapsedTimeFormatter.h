//
//  VElapsedTimeFormatter.h
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import <Foundation/Foundation.h>

/**
 A formatter for creating strings (e.g. "4:59", "0:04", etc) from CMTime objects
 */
@interface VElapsedTimeFormatter : NSObject

/**
 Returns a string describing the value in the time argument.
 */
- (NSString *)stringForCMTime:(CMTime)time;

@end
