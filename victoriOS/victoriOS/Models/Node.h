//
//  Node.h
//  victoriOS
//
//  Created by Will Long on 11/26/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset, Interaction, NodeAction, Sequence;

@interface Node : NSManagedObject

@property (nonatomic, retain) NSNumber * node_id;
@property (nonatomic, retain) NSNumber * display_order;
@property (nonatomic, retain) NSSet *assets;
@property (nonatomic, retain) NSSet *interactions;
@property (nonatomic, retain) Sequence *sequence;
@property (nonatomic, retain) NodeAction *result_action;
@end

@interface Node (CoreDataGeneratedAccessors)

- (void)addAssetsObject:(Asset *)value;
- (void)removeAssetsObject:(Asset *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

- (void)addInteractionsObject:(Interaction *)value;
- (void)removeInteractionsObject:(Interaction *)value;
- (void)addInteractions:(NSSet *)values;
- (void)removeInteractions:(NSSet *)values;

@end
