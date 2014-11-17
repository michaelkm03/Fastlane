//
//  VAdBreak.h
//  victorious
//
//  Created by Lawrence Leach on 11/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAdBreakFallback, VSequence;

@interface VAdBreak : NSManagedObject

@property (nonatomic, retain) NSNumber * startPosition;
@property (nonatomic, retain) NSOrderedSet *fallbacks;
@property (nonatomic, retain) VSequence *sequence;
@end

@interface VAdBreak (CoreDataGeneratedAccessors)

- (void)insertObject:(VAdBreakFallback *)value inFallbacksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFallbacksAtIndex:(NSUInteger)idx;
- (void)insertFallbacks:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFallbacksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFallbacksAtIndex:(NSUInteger)idx withObject:(VAdBreakFallback *)value;
- (void)replaceFallbacksAtIndexes:(NSIndexSet *)indexes withFallbacks:(NSArray *)values;
- (void)addFallbacksObject:(VAdBreakFallback *)value;
- (void)removeFallbacksObject:(VAdBreakFallback *)value;
- (void)addFallbacks:(NSOrderedSet *)values;
- (void)removeFallbacks:(NSOrderedSet *)values;
@end
