//
//  VStatSequence.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatInteraction, VUser;

@interface VStatSequence : NSManagedObject

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
@property (nonatomic, retain) VUser *user;
@end

@interface VStatSequence (CoreDataGeneratedAccessors)

- (void)addInteraction_detailsObject:(VStatInteraction *)value;
- (void)removeInteraction_detailsObject:(VStatInteraction *)value;
- (void)addInteraction_details:(NSSet *)values;
- (void)removeInteraction_details:(NSSet *)values;

@end
