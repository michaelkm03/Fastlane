//
//  VDummyModels.m
//  victorious
//
//  Created by Patrick Lynch on 10/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDummyModels.h"
#import "VVoteResult.h"
#import "victorious-Swift.h"

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

// Suppress a warning we get from importing victorious-Swift.h. Can remove once we convert more of our tests to Swift.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-selector-match"

+ (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass
{
    NSManagedObjectContext *context = [VDummyModels context];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    return [[subclass alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    return nil;
}

#pragma clang diagnostic pop

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
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"voteTypes" ofType:@"json"]] options:0 error:nil];
    NSArray *voteTypes = configuration[@"voteTypes"];
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSDictionary *voteTypeDict in voteTypes)
    {
        VDependencyManager *dm = [[VDependencyManager alloc] initWithParentManager:nil configuration:voteTypeDict dictionaryOfClassesByTemplateName:nil];
        VVoteType *voteType = [[VVoteType alloc] initWithDependencyManager:dm];
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
        user.displayName = [NSString stringWithFormat:@"user_%lu", (unsigned long)i];
        user.remoteId = @(i);
        [models addObject:user];
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
