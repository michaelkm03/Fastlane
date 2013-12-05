//
//  NSManagedObject+EasyFetching.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self)
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
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

+ (RKEntityMapping*)entityMapping
{
    return nil;
}

@end