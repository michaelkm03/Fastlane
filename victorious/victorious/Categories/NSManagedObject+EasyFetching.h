//
//  NSManagedObject+EasyFetching.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EasyFetching)

+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsWithSortKey:(NSString*)sortKey;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context withSortKey:(NSString*)sortKey;

+ (NSString *)entityName;
+ (RKEntityMapping*)entityMapping;

@end
