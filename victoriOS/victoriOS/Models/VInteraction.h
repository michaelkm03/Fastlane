//
//  VInteraction.h
//  victoriOS
//
//  Created by David Keegan on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswer, VInteractionAction, VNode, VRule;

@interface VInteraction : NSManagedObject

@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSNumber * timeout;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *answers;
@property (nonatomic, retain) VInteractionAction *interactionAction;
@property (nonatomic, retain) VNode *node;
@property (nonatomic, retain) NSSet *rules;
@end

@interface VInteraction (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(VAnswer *)value;
- (void)removeAnswersObject:(VAnswer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

- (void)addRulesObject:(VRule *)value;
- (void)removeRulesObject:(VRule *)value;
- (void)addRules:(NSSet *)values;
- (void)removeRules:(NSSet *)values;

@end
