//
//  VStatInteraction.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatAnswer, VStatSequence;

@interface VStatInteraction : NSManagedObject

@property (nonatomic, retain) NSNumber * answered_at;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * interaction_id;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) VStatSequence *stat_sequence;
@end

@interface VStatInteraction (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(VStatAnswer *)value;
- (void)removeAnswersObject:(VStatAnswer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
