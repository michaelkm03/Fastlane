//
//  VInteraction+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VInteraction+Fetcher.h"
#import "VInteraction+RestKit.h"
#import "VNode.h"

@implementation VInteraction (Fetcher)

+ (NSArray*)orderedInteractionsForNode:(VNode*)node
{
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VInteraction entityName]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate* nodeFilter = [NSPredicate predicateWithFormat:@"node.remoteId == %@",
                               node.remoteId];
    [request setPredicate:nodeFilter];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in findAllObjects: %@", error);
    }
    
    return results;
}

@end
