//
//  VEnvironment+VDataCacheID.m
//  victorious
//
//  Created by Josh Hinman on 7/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VDataCacheID.h"
#import "VEnvironment+VDataCacheID.h"

@implementation VEnvironment (VDataCacheID)

- (id<VDataCacheID>)templateCacheIdentifier
{
    return [NSString stringWithFormat:@"VEnvironment.%@.template", self.name];
}

@end
