//
//  VNodeAction.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode;

@interface VNodeAction : NSManagedObject

@property (nonatomic, retain) NSNumber * lost_goto_node;
@property (nonatomic, retain) NSNumber * won_goto_node;
@property (nonatomic, retain) VNode *node;

@end
