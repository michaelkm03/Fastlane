//
//  Interaction.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, InteractionAction, Node, Rule;

@interface Interaction : NSManagedObject

@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * interaction_id;
@property (nonatomic, retain) NSNumber * node_id;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * start_time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) InteractionAction *interaction_action;
@property (nonatomic, retain) Node *node;
@property (nonatomic, retain) NSSet *rules;
@end

@interface Interaction (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Answer *)value;
- (void)removeAnswersObject:(Answer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

- (void)addRulesObject:(Rule *)value;
- (void)removeRulesObject:(Rule *)value;
- (void)addRules:(NSSet *)values;
- (void)removeRules:(NSSet *)values;

@end
