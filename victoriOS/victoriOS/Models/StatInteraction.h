//
//  StatInteraction.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatAnswer, StatSequence;

@interface StatInteraction : NSManagedObject

@property (nonatomic, retain) NSNumber * answered_at;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * interaction_id;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) StatSequence *stat_sequence;
@end

@interface StatInteraction (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(StatAnswer *)value;
- (void)removeAnswersObject:(StatAnswer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
