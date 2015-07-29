//
//  NSString+VDataCacheID.h
//  victorious
//
//  Created by Josh Hinman on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDataCache.h"

#import <Foundation/Foundation.h>

/**
 Adds VDataCacheID conformance to NSString so that instances
 can be used as cache identifiers in VDataCache
 */
@interface NSString (VDataCacheID) <VDataCacheID>

@end
