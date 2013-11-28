//
//  NodeAction.h
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface NodeAction : NSManagedObject

@property (nonatomic, retain) NSNumber * lost_goto_node;
@property (nonatomic, retain) NSNumber * won_goto_node;
@property (nonatomic, retain) Node *node;

@end
