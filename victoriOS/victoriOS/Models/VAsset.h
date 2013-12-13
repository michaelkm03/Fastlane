//
//  VAsset.h
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) VNode *node;

@end
