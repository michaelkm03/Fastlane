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

typedef NS_ENUM(NSUInteger, VVoteIDs) {
    VVoteTypeLike = 0,
    VVoteTypeDislike
};

@implementation VVoteType (Fetcher)

+ (VVoteType*)likeVote
{
    return [self voteAtIndex:VVoteTypeLike];
}

+ (VVoteType*)dislikeVote
{
    return [self voteAtIndex:VVoteTypeDislike];
}

+ (VVoteType *)voteAtIndex:(NSUInteger)index
{
    NSAssert([NSThread isMainThread], @"voteAtIndex needs to be called on the main thread");
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VVoteType entityName]];
    NSManagedObjectContext* context = [VObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    NSSortDescriptor*   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error = nil;
    NSArray* allVoteTypes = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
        return nil;
    }
    
    if (index >= [allVoteTypes count])
    {
        return nil;
    }
    
    return [allVoteTypes objectAtIndex:index];
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
