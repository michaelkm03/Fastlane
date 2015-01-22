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
- (NSString *)v_firstNonSlashPathComponent;

/**
 Returns a pathComponent at the specified index or nil if no such pathComponent exists.
 This does not ignore slashes like the method `v_firstNonFlashPathComponent`.
 */
- (NSString *)v_pathComponentAtIndex:(NSUInteger)index;

@end
