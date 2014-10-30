//
//  VAdBreak.h
//  victorious
//
//  Created by Lawrence Leach on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAdBreakFallback, VSequence;

@interface VAdBreak : NSManagedObject

@property (nonatomic, retain) NSNumber * startPosition;
@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) NSSet *fallbacks;
@end

@interface VAdBreak (CoreDataGeneratedAccessors)

- (void)addFallbacksObject:(VAdBreakFallback *)value;
- (void)removeFallbacksObject:(VAdBreakFallback *)value;
- (void)addFallbacks:(NSSet *)values;
- (void)removeFallbacks:(NSSet *)values;

@end
