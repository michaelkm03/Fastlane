//
//  VEnvironment+VDataCacheID.h
//  victorious
//
//  Created by Josh Hinman on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDataCache.h"
#import "VEnvironment.h"

@interface VEnvironment (VDataCacheID)

/**
 Returns an ID that can be used to store and retrieve
 template data fro this environment in an instance of
 VDataCache.
 */
- (id<VDataCacheID>)templateCacheIdentifier;

@end
