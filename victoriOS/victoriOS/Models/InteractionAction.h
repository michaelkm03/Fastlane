//
//  InteractionAction.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interaction;

@interface InteractionAction : NSManagedObject

@property (nonatomic, retain) NSNumber * correct_goto_node;
@property (nonatomic, retain) NSNumber * incorrect_goto_node;
@property (nonatomic, retain) NSNumber * timeout_goto_node;
@property (nonatomic, retain) Interaction *relationship;

@end
