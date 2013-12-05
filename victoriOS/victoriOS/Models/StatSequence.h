//
//  StatSequence.h
//  victoriOS
//
//  Created by Will Long on 12/4/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatInteraction, User;

@interface StatSequence : NSManagedObject

@property (nonatomic, retain) NSDate * completed_at;
@property (nonatomic, retain) NSNumber * correct_answers;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * num_questions_answered;
@property (nonatomic, retain) NSString * outcome;
@property (nonatomic, retain) NSNumber * possible_points;
@property (nonatomic, retain) NSNumber * total_points;
@property (nonatomic, retain) NSNumber * total_questions;
@property (nonatomic, retain) NSSet *interaction_details;
@property (nonatomic, retain) User *user;
@end

@interface StatSequence (CoreDataGeneratedAccessors)

- (void)addInteraction_detailsObject:(StatInteraction *)value;
- (void)removeInteraction_detailsObject:(StatInteraction *)value;
- (void)addInteraction_details:(NSSet *)values;
- (void)removeInteraction_details:(NSSet *)values;

@end
