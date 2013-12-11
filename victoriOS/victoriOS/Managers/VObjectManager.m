//
//  VObjectManager.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VObjectManager.h"
#import "NSString+SHA1Digest.h"
#import "VUser+RestKit.h"
#import "VCategory+RestKit.h"
#import "VSequence+RestKit.h"
#import "VStatSequence+RestKit.h"

@implementation VObjectManager

+ (void)setupObjectManager
{
#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif

    VObjectManager *manager = [self managerWithBaseURL:[NSURL URLWithString:VBASEURL]];

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

    [manager addResponseDescriptorsFromArray:[self descriptors]];

    //This will allow us to call this manager with [RKObjectManager sharedManager]
    [self setSharedManager:manager];
}

+ (NSArray *)descriptors
{
    //Should one of our requests to get data fail, RestKit will use this mapping and send us an NSError object with the error message of the response as the string.
    NSMutableIndexSet *statusCodes = [RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError) mutableCopy];
    [statusCodes addIndexes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    // TODO: store more of the error information in a RKObjectMapping subclass, like the error code
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

#pragma mark - operation

+ (RKManagedObjectRequestOperation *)requestMethod:(RKRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error))block
{
    // TODO: return accurate page and perPage
    RKManagedObjectRequestOperation *requestOperation =
    [[self sharedManager] appropriateObjectRequestOperationWithObject:nil method:method path:path parameters:parameters];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if(block){
            if([[mappingResult firstObject] isKindOfClass:[RKErrorMessage class]]){
                RKErrorMessage *errorMessage = (RKErrorMessage *)[mappingResult firstObject];
                // TODO: create better error object
                block(0, 0, nil, [NSError errorWithDomain:@"com.getvictorious.victoriOS" code:0
                                           userInfo:@{NSLocalizedDescriptionKey: errorMessage.errorMessage}]);
            }else{
                block(0, 0, mappingResult.array, nil);
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        if(block){
            block(0, 0, nil, error);
        }
    }];

    return requestOperation;
}

+ (RKManagedObjectRequestOperation *)GET:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error))block
{
    return [self requestMethod:RKRequestMethodGET path:path parameters:parameters block:block];
}

+ (RKManagedObjectRequestOperation *)POST:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *results, NSError *error))block
{
    return [self requestMethod:RKRequestMethodPOST path:path parameters:parameters block:block];
}

#pragma mark - Subclass

- (id)appropriateObjectRequestOperationWithObject:(id)object
                                           method:(RKRequestMethod)method
                                             path:(NSString *)path
                                       parameters:(NSDictionary *)parameters
{
    
    AFHTTPClient* client = [self HTTPClient];
    
    NSString *currentDate = [self rFC2822DateTimeString];
    NSString* userAgent = [client.defaultHeaders objectForKey:@"User-Agent"];
    
    VUser* mainUser = [[VUser findAllObjects] firstObject];
    
    // Build string to be hashed.
    NSString *sha1String = [[NSString stringWithFormat:@"%@%@%@%@%@",
                             currentDate,
                             path,
                             userAgent,
                             mainUser.token,
                             RKStringFromRequestMethod(method)] SHA1HexDigest];
    
    VLog(@"sha1String before sha1: %@", [NSString stringWithFormat:@"%@%@%@%@%@",
                                         currentDate,
                                         path,
                                         userAgent,
                                         mainUser.token,
                                         RKStringFromRequestMethod(method)]);
    
    NSNumber* userID = mainUser.id;
    sha1String = [NSString stringWithFormat:@"Basic %@:%@", userID, sha1String];
    
    [client setDefaultHeader:@"Authorization" value:sha1String];
    [client setDefaultHeader:@"Date" value:currentDate];
    

    return [super appropriateObjectRequestOperationWithObject:object
                                                       method:method
                                                         path:path
                                                   parameters:parameters];
}

- (NSString *)rFC2822DateTimeString {
    
    static NSDateFormatter *sRFC2822DateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sRFC2822DateFormatter = [[NSDateFormatter alloc] init];
        sRFC2822DateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z"; //RFC2822-Format
    });
    
    return [sRFC2822DateFormatter stringFromDate:[NSDate date]];
}
@end
