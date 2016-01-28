//
//  NSCharacterSet+VSDKURLParts.h
//  victorious
//
//  Created by Josh Hinman on 2/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (VURLParts)

/**
 Returns a character set of allowed characters in a part of a URL path
 (i.e., all the allowed characters in the path as a whole, minus the
 path separator character)
 */
+ (NSCharacterSet *)vsdk_pathPartCharacterSet;

/**
 Returns a character set of allowed characters in a query parameter or value (i.e.,
 all the allowed characters in the query as a whole, minus ?, &, and =)
 */
+ (NSCharacterSet *)vsdk_queryPartCharacterSet;

@end
