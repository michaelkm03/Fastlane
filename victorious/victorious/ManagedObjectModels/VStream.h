//
//  VStream.h
//  victorious
//
//  Created by Michael Sena on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

@class VStreamItem;

@interface VStream : VStreamItem

@property (nonatomic, retain) NSString * apiPath;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * filterName;
@property (nonatomic, retain) NSOrderedSet *streamItems;
@property (nonatomic, retain) NSString * hashtag;
@property (nonatomic, retain) NSString * trackingIdentifier;
@end

@interface VStream (CoreDataGeneratedAccessors)

- (void)insertObject:(VStreamItem *)value inStreamItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStreamItemsAtIndex:(NSUInteger)idx;
- (void)insertStreamItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStreamItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStreamItemsAtIndex:(NSUInteger)idx withObject:(VStreamItem *)value;
- (void)replaceStreamItemsAtIndexes:(NSIndexSet *)indexes withStreamItems:(NSArray *)values;
- (void)addStreamItemsObject:(VStreamItem *)value;
- (void)removeStreamItemsObject:(VStreamItem *)value;
- (void)addStreamItems:(NSOrderedSet *)values;
- (void)removeStreamItems:(NSOrderedSet *)values;
@end
