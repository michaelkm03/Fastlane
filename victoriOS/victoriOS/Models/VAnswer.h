//
//  VAnswer.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswerAction, VInteraction;

@interface VAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) VAnswerAction *answer_action;
@property (nonatomic, retain) VInteraction *interaction;

@end
