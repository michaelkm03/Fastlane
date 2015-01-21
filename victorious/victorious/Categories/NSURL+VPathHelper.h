//
//  NSURL+VPathHelper.h
//  victorious
//
//  Created by Josh Hinman on 1/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VPathHelper)

/**
 Returns the first pathComponent that is not equal
 to "/", or nil if no such pathComponent exists.
 */
- (NSString *)firstNonSlashPathComponent;

@end
