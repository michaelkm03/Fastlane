//
//  VAsset.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) VNode *node;

@end
