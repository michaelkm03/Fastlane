//
//  StatAnswer.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatInteraction;

@interface StatAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) StatInteraction *interaction;

@end
