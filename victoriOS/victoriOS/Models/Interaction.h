//
//  Interaction.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Interaction : NSManagedObject

@property (nonatomic, retain) NSNumber * interaction_id;
@property (nonatomic, retain) NSNumber * node_id;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * start_time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) NSManagedObject *node;
@end

@interface Interaction (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(NSManagedObject *)value;
- (void)removeAnswersObject:(NSManagedObject *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
