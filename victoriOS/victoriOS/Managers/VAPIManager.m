//
//  VAPIManager.m
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VAPIManager.h"
#import "VObjectManager.h"
#import "VUser+RestKit.h"
#import "VCategory+RestKit.h"
#import "VSequence+RestKit.h"
#import "VStatSequence+RestKit.h"

@implementation VAPIManager

#pragma mark - RestKit Methods

+ (void)setupRestKit
{

#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif

    RKObjectManager *manager = [VObjectManager managerWithBaseURL:[NSURL URLWithString:VBASEURL]];

    //Add the App ID to the User-Agent field
    //(this is the only non-dynamic header, so set it now)
    NSString *userAgent = [[manager HTTPClient].defaultHeaders objectForKey:@"User-Agent"];

    //TODO: use real app id once we set that up
    userAgent = [NSString stringWithFormat:@"%@ aid:%@", userAgent, @"1"];
    [[manager HTTPClient] setDefaultHeader:@"User-Agent" value:userAgent];

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"victoriOS" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];

    manager.managedObjectStore = managedObjectStore;

    // Initialize the Core Data stack
    NSError *error = nil;
    [managedObjectStore createPersistentStoreCoordinator];
    [managedObjectStore addInMemoryPersistentStore:&error];
    [managedObjectStore createManagedObjectContexts];

    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];

    [[RKObjectManager sharedManager] addResponseDescriptorsFromArray:[self descriptors]];

    //This will allow us to call this manager with [RKObjectManager sharedManager]
    [RKObjectManager setSharedManager:manager];
}

+ (NSArray *)descriptors
{
    //Should one of our requests to get data fail, RestKit will use this mapping and send us an NSError object with the error message of the response as the string.
    NSMutableIndexSet *statusCodes = [RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError) mutableCopy];
    [statusCodes addIndexes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message"
                                                                           toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny
                                            pathPattern:nil keyPath:nil statusCodes:statusCodes];

    return @[errorDescriptor,
             [VUser descriptor],
             [VCategory descriptor],
             [VSequence sequenceListDescriptor],
             [VSequence sequenceFullDataDescriptor],
             [VComment descriptor],
             [VComment getAllDescriptor],
             [VStatSequence gamesPlayedDescriptor],
             [VStatSequence gameStatsDescriptor]];
}

@end
