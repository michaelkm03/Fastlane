//
//  Asset.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Node;

@interface Asset : NSManagedObject

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSNumber * node_id;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Node *node;

@end
