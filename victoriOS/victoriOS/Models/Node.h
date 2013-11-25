//
//  Node.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interaction;

@interface Node : NSManagedObject

@property (nonatomic, retain) NSNumber * node_id;
@property (nonatomic, retain) NSSet *actions;
@property (nonatomic, retain) NSSet *assets;
@property (nonatomic, retain) NSSet *interactions;
@property (nonatomic, retain) NSManagedObject *sequence;
@end

@interface Node (CoreDataGeneratedAccessors)

- (void)addActionsObject:(NSManagedObject *)value;
- (void)removeActionsObject:(NSManagedObject *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (void)addAssetsObject:(NSManagedObject *)value;
- (void)removeAssetsObject:(NSManagedObject *)value;
- (void)addAssets:(NSSet *)values;
- (void)removeAssets:(NSSet *)values;

- (void)addInteractionsObject:(Interaction *)value;
- (void)removeInteractionsObject:(Interaction *)value;
- (void)addInteractions:(NSSet *)values;
- (void)removeInteractions:(NSSet *)values;

@end
