//
//  VConversation+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+Fetcher.h"
#import "NSManagedObject+EasyFetching.h"

#import "VObjectManager.h"
#import "VMessage.h"

@implementation VConversation (Fetcher)

- (NSDate*) lastPostDate
{
    NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:[VMessage entityName]
                                              inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    request.predicate = [NSPredicate predicateWithFormat:@"conversation.remoteId == %@", self.remoteId];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"postedAt" ascending:YES];
    [request setSortDescriptors:@[sort]];
    [request setFetchBatchSize:1];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in lastPostDate: %@", error);
    }

    if ([[results firstObject] isKindOfClass:[NSDate class]])
        return [results firstObject];
    
    return nil;
}
@end
