//
//  VDummyModels.m
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDummyModels.h"
#import "VObjectManager.h"
#import "RKManagedObjectStore.h"

static NSManagedObjectContext *context = nil;

@implementation VDummyModels

+ (NSManagedObjectContext *)context
{
    if ( context == nil )
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"victoriOS" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:storeCoordinator];
    }
    return context;
}

+ (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass
{
    NSManagedObjectContext *context = [VDummyModels context];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    return [[subclass alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    return nil;
}

+ (NSArray *)objectsWithEntityName:(NSString *)entityName subclass:(Class)subclass count:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        id model = [self objectWithEntityName:entityName subclass:subclass];
        [models addObject:model];
    }
    return [NSArray arrayWithArray:models];
}

+ (NSArray *)createVoteTypes:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VVoteType *voteType = (VVoteType *)[self objectWithEntityName:@"VoteType" subclass:[VVoteType class]];
        voteType.name = [NSString stringWithFormat:@"voteType_%lu", (unsigned long)i];
        voteType.remoteId = @(i+1);
        voteType.displayOrder = @(i+1);
        voteType.images = @[ @"http://www.domain.com/image.png", @"http://www.domain.com/image.png", @"http://www.domain.com/image.png" ];
        [models addObject:voteType];
    }
    return [NSArray arrayWithArray:models];
}

+ (NSArray *)createUsers:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VUser *user = (VUser *)[self objectWithEntityName:@"User" subclass:[VUser class]];
        user.name = [NSString stringWithFormat:@"user_%lu", (unsigned long)i];
        user.remoteId = @(i);
        [models addObject:user];
    }
    return [NSArray arrayWithArray:models];
}

/*+ (NSArray *)createHashtags:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VHashtag *hashtag = (VHashtag *)[self objectWithEntityName:@"Hashtag" subclass:[VHashtag class]];
        hashtag.tag = [NSString stringWithFormat:@"hashtag_%lu", (unsigned long)i];
        [models addObject:hashtag];
    }
    return [NSArray arrayWithArray:models];
}*/
@end
