//
//  VNodeAction.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode;

@interface VNodeAction : NSManagedObject

@property (nonatomic, retain) NSNumber * lostGotoNode;
@property (nonatomic, retain) NSNumber * wonGotoNode;
@property (nonatomic, retain) VNode *node;

@end
