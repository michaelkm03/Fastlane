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
#import "VUser.h"
#import "VVoteResult.h"
#import "VTracking.h"

static NSManagedObjectContext *context = nil;

NSString * const kMacroBallisticsCount = @"%%COUNT%%";

@implementation VDummyModels

+ (NSManagedObjectContext *)context
{
    if ( !context )
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
        voteType.iconImage = @"https://www.google.com/images/icons/product/chrome-48.png";
        voteType.imageFormat = @"https://www.google.com/images/icons/product/XXXXX.png";
        voteType.imageCount = @(5);
        voteType.displayOrder = @(i+1);
        
        NSString *trackingUrl = [NSString stringWithFormat:@"http://www.tracking.com/%@", kMacroBallisticsCount];
        voteType.tracking = (VTracking *)[VDummyModels objectWithEntityName:@"Tracking" subclass:[VTracking class]];
        voteType.tracking.ballisticCount = @[ trackingUrl, trackingUrl, trackingUrl ];
        
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

+ (NSArray *)createHashtags:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VHashtag *hashtag = (VHashtag *)[self objectWithEntityName:@"Hashtag" subclass:[VHashtag class]];
        hashtag.tag = [NSString stringWithFormat:@"hashtag_%lu", (unsigned long)i];
        [models addObject:hashtag];
    }
    return [NSArray arrayWithArray:models];
}

+ (NSArray *)createVoteResults:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VVoteResult *result = (VVoteResult *)[self objectWithEntityName:@"VoteResult" subclass:[VVoteResult class]];
        result.count = @( arc4random() % 100 );
        result.remoteId = @(i+1);
        [models addObject:result];
    }
    return [NSArray arrayWithArray:models];
}

@end
