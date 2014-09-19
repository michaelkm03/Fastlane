//
//  VStream.h
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VDirectoryItem.h"

@class VSequence;

@interface VStream : VDirectoryItem

@property (nonatomic, retain) NSString * apiPath;
@property (nonatomic, retain) NSString * streamContentType;
@property (nonatomic, retain) NSOrderedSet *sequences;
@end

@interface VStream (CoreDataGeneratedAccessors)

- (void)insertObject:(VSequence *)value inSequencesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSequencesAtIndex:(NSUInteger)idx;
- (void)insertSequences:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSequencesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSequencesAtIndex:(NSUInteger)idx withObject:(VSequence *)value;
- (void)replaceSequencesAtIndexes:(NSIndexSet *)indexes withSequences:(NSArray *)values;
- (void)addSequencesObject:(VSequence *)value;
- (void)removeSequencesObject:(VSequence *)value;
- (void)addSequences:(NSOrderedSet *)values;
- (void)removeSequences:(NSOrderedSet *)values;
@end
