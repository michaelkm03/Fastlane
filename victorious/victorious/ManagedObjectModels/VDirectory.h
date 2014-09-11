//
//  VDirectory.h
//  victorious
//
//  Created by Will Long on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VDirectoryItem.h"

@class VDirectoryItem;

@interface VDirectory : VDirectoryItem

@property (nonatomic, retain) NSOrderedSet *directoryItems;
@end

@interface VDirectory (CoreDataGeneratedAccessors)

- (void)insertObject:(VDirectoryItem *)value inDirectoryItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDirectoryItemsAtIndex:(NSUInteger)idx;
- (void)insertDirectoryItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDirectoryItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDirectoryItemsAtIndex:(NSUInteger)idx withObject:(VDirectoryItem *)value;
- (void)replaceDirectoryItemsAtIndexes:(NSIndexSet *)indexes withDirectoryItems:(NSArray *)values;
- (void)addDirectoryItemsObject:(VDirectoryItem *)value;
- (void)removeDirectoryItemsObject:(VDirectoryItem *)value;
- (void)addDirectoryItems:(NSOrderedSet *)values;
- (void)removeDirectoryItems:(NSOrderedSet *)values;
@end
