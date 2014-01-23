//
//  NSManagedObject+EasyFetching.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "NSManagedObject+EasyFetching.h"

@implementation NSManagedObject (EasyFetching)

+ (NSArray *)findAllObjects
{
    return [self findAllObjectsWithSortKey:nil];
}

+ (NSArray *)findAllObjectsWithSortKey:(NSString*)sortKey
{
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
    
    return [self findAllObjectsInContext:context withSortKey:sortKey];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context withSortKey:(NSString*)sortKey
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[self entityName]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    [request setSortDescriptors:@[sort]];
    [request setFetchBatchSize:50];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in findAllObjects: %@", error);
    }
    return results;
}

+ (NSString *)entityName
{
    return nil;
}

+ (RKEntityMapping*)entityMapping
{
    return nil;
}

@end