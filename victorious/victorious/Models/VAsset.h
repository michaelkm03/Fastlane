//
//  VAsset.h
//  victorious
//
//  Created by Will Long on 3/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode, VVoteType;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) VNode *node;
@property (nonatomic, retain) VVoteType *vote;

@end
