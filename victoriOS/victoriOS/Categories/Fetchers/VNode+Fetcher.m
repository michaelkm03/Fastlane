//
//  VNode+Fetcher.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VNode+Fetcher.h"
#import "VNode+RestKit.h"

#import "VSequence.h"

@implementation VNode (Fetcher)


+ (NSArray*)orderedNodesForSequence:(VSequence*)sequence
{
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[VNode entityName]
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate* sequenceFilter = [NSPredicate predicateWithFormat:@"sequence.remoteId == %@",
                                   sequence.remoteId];
    [request setPredicate:sequenceFilter];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in findAllObjects: %@", error);
    }
    
    return results;
}

@end
