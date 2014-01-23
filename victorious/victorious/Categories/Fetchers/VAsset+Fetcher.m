//
//  VAsset+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VAsset+Fetcher.h"
#import "VAsset+RestKit.h"
#import "VNode.h"

@implementation VAsset (Fetcher)

+ (NSArray*)orderedAssetsForNode:(VNode*)node
{
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VAsset entityName]];
    
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
