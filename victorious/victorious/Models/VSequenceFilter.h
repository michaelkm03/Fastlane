//
//  VSequenceFilter.h
//  victorious
//
//  Created by Will Long on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VAbstractFilter.h"

@class VSequence;

@interface VSequenceFilter : VAbstractFilter

@property (nonatomic, retain) NSSet *sequences;
@end

@interface VSequenceFilter (CoreDataGeneratedAccessors)

- (void)addSequencesObject:(VSequence *)value;
- (void)removeSequencesObject:(VSequence *)value;
- (void)addSequences:(NSSet *)values;
- (void)removeSequences:(NSSet *)values;

@end
