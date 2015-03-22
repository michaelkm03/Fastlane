//
//  NSArray+VMap.h
//  victorious
//
//  Created by Josh Hinman on 6/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (VMap)

/**
 Returns a new array by transforming the objects 
 in the receiver with the specified block
 */
- (NSArray *)v_map:(id(^)(id))transform;

/**
 Returns a new array by transforming the objects
 in the receiver with the specified block
 and flattening the results
 */
- (NSArray *)v_flatMap:(NSArray *(^)(id))transform;

@end
