//
//  VVoteType+Fetcher.m
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType+Fetcher.h"
#import "VVoteType+RestKit.h"

#import "VObjectManager.h"

@implementation VVoteType (Fetcher)

+ (NSArray*)allVoteTypes
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VVoteType entityName]];
    NSManagedObjectContext* context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;

    NSError *error = nil;
    NSArray* allVoteTypes = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
        return nil;
    }
    
    return allVoteTypes;
}

- (NSArray*)imageURLs
{
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    for (NSString* urlString in (NSArray*)self.images)
    {
        [urls addObject:[NSURL URLWithString:urlString]];
    }
    return urls;
}

@end
