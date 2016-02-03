//
//  VStream.h
//  victorious
//
//  Created by Sharif Ahmed on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

NS_ASSUME_NONNULL_BEGIN

@class VStreamItem;

@interface VStream : VStreamItem

@property (nonatomic, retain, nullable) NSString * apiPath;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain, nullable) NSString * filterName;
@property (nonatomic, retain, nullable) NSString * hashtag;
@property (nonatomic, retain, nullable) NSNumber * isUserPostAllowed;
@property (nonatomic, retain, nullable) NSString * trackingIdentifier;
@property (nonatomic, retain, nullable) NSString * shelfId;
//@property (nonatomic, retain) NSOrderedSet *marqueeItems;
//@property (nonatomic, retain) NSOrderedSet *streamItems;

@end

@interface VStream (CoreDataGeneratedAccessors)

- (void)insertObject:(VStreamItem *)value inMarqueeItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMarqueeItemsAtIndex:(NSUInteger)idx;
- (void)insertMarqueeItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMarqueeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMarqueeItemsAtIndex:(NSUInteger)idx withObject:(VStreamItem *)value;
- (void)replaceMarqueeItemsAtIndexes:(NSIndexSet *)indexes withMarqueeItems:(NSArray *)values;
- (void)addMarqueeItemsObject:(VStreamItem *)value;
- (void)removeMarqueeItemsObject:(VStreamItem *)value;
- (void)addMarqueeItems:(NSOrderedSet *)values;
- (void)removeMarqueeItems:(NSOrderedSet *)values;
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

NS_ASSUME_NONNULL_END
