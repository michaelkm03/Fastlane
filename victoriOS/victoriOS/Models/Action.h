//
//  Action.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer;

@interface Action : NSManagedObject

@property (nonatomic, retain) NSNumber * goto_node;
@property (nonatomic, retain) Answer *answer;

@end
