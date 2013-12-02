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
    RKObjectManager* manager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;

    return [self findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(self)
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        //TODO: log error
    }
    return results;
}

+(RKEntityMapping*)entityMapping
{
    return nil;
}

@end