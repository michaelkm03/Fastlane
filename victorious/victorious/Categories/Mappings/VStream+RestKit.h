//
//  VStream+RestKit.h
//  victorious
//
//  Created by Will Long on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface VStream (RestKit)

+ (NSArray *)descriptors;

+ (NSDictionary *)propertyMap;

+ (NSString *)entityName;

/**
    Adjusts the provided mapping so that it maps objects from its array of "items" to
        appropriate stream items.
 
    @param mapping The mapping that should be updated.
 */
+ (void)addFeedChildMappingToMapping:(RKEntityMapping *)mapping;

@end

NS_ASSUME_NONNULL_END
