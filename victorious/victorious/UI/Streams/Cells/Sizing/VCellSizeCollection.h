//
//  VCellSizeCollection.h
//  victorious
//
//  Created by Patrick Lynch on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCellSizeComponent.h"

/**
 A key used internally to identify size of layouts for caching purposes.
 */
extern NSString * const VCellSizeCacheKey;

/*
 A key used to identify the array of comments used in creating the size.
 */
extern NSString * const VCellSizingCommentsKey;

/**
 An object used by stream cells to model the constant and dynamic sizes of its components,
 then use that modelling to calculate the cell size required when displayed in a
 collection view.
 */
@interface VCellSizeCollection : NSObject

/**
 Add a constant size to this layout, which will never change depending on the content
 of the cell or its subcomponents.
 */
- (void)addComponentWithConstantSize:(CGSize)constantSize;

/**
 Add a dynamic size, i.e. a block that calculates size based on some content in the cell.
 The block will be called during size calculations and should return the additional size
 required to accomodate some sub-component of a cell.
 */
- (void)addComponentWithDynamicSize:(VDynamicCellSizeBlock)dynamicSize;

/**
 Calculates the total size requires for the layout by adding all dynamic and constant
 layout components that have been added.  The return value represented the size required
 to properly display all sub-components of a collection view cell.
 
 @param base A starting size, usually dictated by the bounds of the colleciton view that
 will display the collection view cell for which we are calculating size.
 */
- (CGSize)totalSizeWithBaseSize:(CGSize)base userInfo:(NSDictionary *)userInfo;

/**
 Removes the size registered for the provided key from the cache.
 
 @param key The key that was used to initially cache the size value.
 */
- (void)removeSizeCacheForItemWithCacheKey:(NSString *)key;

/**
 Retrieves the comments used to create the sizing information for the given cache key.
    This should be the same cache key used when creating the sizing information.
 
 @param key The cache key that identifies this sizing information.
 
 @return An array of comments that were used in sizing this cell.
 */
- (NSArray *)commentsForCacheKey:(NSString *)key;

@end
