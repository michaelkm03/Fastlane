//
//  VSequenceFilter.h
//  victorious
//
//  Created by Will Long on 4/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence;

@interface VSequenceFilter : NSManagedObject

@property (nonatomic, retain) NSString * filterAPIPath;
@property (nonatomic, retain) NSNumber * maxPageNumber;
@property (nonatomic, retain) NSNumber * nextPageNumber;
@property (nonatomic, retain) NSNumber * perPageNumber;
@property (nonatomic, retain) NSSet *sequences;
@end

@interface VSequenceFilter (CoreDataGeneratedAccessors)

- (void)addSequencesObject:(VSequence *)value;
- (void)removeSequencesObject:(VSequence *)value;
- (void)addSequences:(NSSet *)values;
- (void)removeSequences:(NSSet *)values;

@end
