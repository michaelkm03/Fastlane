//
//  Answer.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnswerAction, Interaction;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) AnswerAction *answer_action;
@property (nonatomic, retain) Interaction *interaction;

@end
