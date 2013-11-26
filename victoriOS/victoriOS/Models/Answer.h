//
//  Answer.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Interaction;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSSet *action;
@property (nonatomic, retain) Interaction *interaction;
@end

@interface Answer (CoreDataGeneratedAccessors)

- (void)addActionObject:(Action *)value;
- (void)removeActionObject:(Action *)value;
- (void)addAction:(NSSet *)values;
- (void)removeAction:(NSSet *)values;

@end
