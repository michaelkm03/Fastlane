//
//  VDummyModels.h
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"

@interface VDummyModels : NSObject

/**
 Initializes a managed object context and creates a new core data object.
 @param entityName The CoreData entity
 @param subclass The NSManagedObject subclass associated with the entity.
 @return An instance of the type provided by the subclass parameter
 */
+ (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass;

/**
 Initializes a managed object context and creates multiple core data objects.
 @param entityName The CoreData entity
 @param subclass The NSManagedObject subclass associated with the entity.
 @param count The number of instances to create.
 @return An array of instances of the type provided by the subclass parameter
 */
+ (NSArray *)objectsWithEntityName:(NSString *)entityName subclass:(Class)subclass count:(NSInteger)count;

// Add more convenience methods as you see fit

+ (NSArray *)createUsers:(NSInteger)count;

+ (NSArray *)createVoteTypes:(NSInteger)count;

+ (NSArray *)createVoteResults:(NSInteger)count;

+ (NSArray *)createUserTags:(NSInteger)count;

+ (NSArray *)createHashtagTags:(NSInteger)count;

@end
