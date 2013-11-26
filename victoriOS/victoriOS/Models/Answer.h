//
//  Answer.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, Interaction;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) Action *answer_action;
@property (nonatomic, retain) Interaction *interaction;

@end
