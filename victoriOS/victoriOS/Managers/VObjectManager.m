//
//  VObjectManager.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VObjectManager.h"

#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"

#import "NSString+SHA1Digest.h"
#import "VErrorMessage.h"

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

    [manager victoriousSetup];

    //This will allow us to call this manager with [RKObjectManager sharedManager]
    [self setSharedManager:manager];
}

- (void)victoriousSetup
{
    //Should one of our requests to get data fail, RestKit will use this mapping and send us an NSError object with the error message of the response as the string.
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:
    [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                         method:RKRequestMethodAny
                                                                                    pathPattern:nil
                                                                                        keyPath:@"error"
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKResponseDescriptor *verrorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[VErrorMessage objectMapping]
                                                                                          method:RKRequestMethodAny
                                                                                     pathPattern:nil
                                                                                         keyPath:nil
                                                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [self addResponseDescriptorsFromArray: @[errorDescriptor,
                                             verrorDescriptor,
             [VUser descriptor],
             [VCategory descriptor],
             [VSequence sequenceListDescriptor],
             [VSequence sequenceFullDataDescriptor],
             [VComment descriptor],
             [VComment getAllDescriptor],
             [VStatSequence gamesPlayedDescriptor],
             [VStatSequence gameStatsDescriptor]]];

    _paginationStatuses = [[NSMutableDictionary alloc] init];
}

#pragma mark - operation

- (RKManagedObjectRequestOperation *)requestMethod:(RKRequestMethod)method
                                            object:(id)object
                                              path:(NSString *)path
                                        parameters:(NSDictionary *)parameters
                                      successBlock:(SuccessBlock)successBlock
                                         failBlock:(FailBlock)failBlock
                                   paginationBlock:(PaginationBlock)paginationBlock
{
    RKManagedObjectRequestOperation *requestOperation =
    [self  appropriateObjectRequestOperationWithObject:object method:method path:path parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         VErrorMessage *errorMessage;
         NSArray* mappedObjects;
         if([[mappingResult firstObject] isKindOfClass:[VErrorMessage class]])
         {
             errorMessage = (VErrorMessage *)[mappingResult firstObject];
             
             //mappedObjects should not contain the VErrorMessage.
             NSArray* allObjects = mappingResult.array;
             NSRange range = NSMakeRange(1, [allObjects count]-1);
             mappedObjects = [allObjects subarrayWithRange:range];
         }
         else
         {
             mappedObjects = mappingResult.array;
         }
         
         if (errorMessage.error && failBlock)
             failBlock([NSError errorWithDomain:@"com.getvictorious.victoriOS" code:errorMessage.error
                                       userInfo:@{NSLocalizedDescriptionKey: errorMessage.message}]);
         else
         {
             if (successBlock)
                 successBlock(mappedObjects);
         
             if(paginationBlock)
                 paginationBlock(errorMessage.page_number, errorMessage.total_pages); //TODO: pass in real page / totalPages
         }
         
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         if(failBlock)
             failBlock(error);
     }];
    
    return requestOperation;
}

- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                                  object:(id)object
                              parameters:(NSDictionary *)parameters
                            successBlock:(SuccessBlock)successBlock
                               failBlock:(FailBlock)failBlock
                         paginationBlock:(PaginationBlock)paginationBlock
{
    return [self requestMethod:RKRequestMethodGET
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock
               paginationBlock:paginationBlock];
}

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                                   object:(id)object
                               parameters:(NSDictionary *)parameters
                             successBlock:(SuccessBlock)successBlock
                                failBlock:(FailBlock)failBlock
                          paginationBlock:(PaginationBlock)paginationBlock
{
    return [self requestMethod:RKRequestMethodPOST
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock
               paginationBlock:paginationBlock];
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
    
    VUser* mainUser = [VObjectManager sharedManager].mainUser;
    NSString* token = mainUser.token ? mainUser.token : @"";
    
    // Build string to be hashed.
    NSString *sha1String = [[NSString stringWithFormat:@"%@%@%@%@%@",
                             currentDate,
                             path,
                             userAgent,
                             token,
                             RKStringFromRequestMethod(method)] SHA1HexDigest];
    
    VLog(@"sha1String before sha1: %@", [NSString stringWithFormat:@"%@%@%@%@%@",
                                         currentDate,
                                         path,
                                         userAgent,
                                         token,
                                         RKStringFromRequestMethod(method)]);
    
    NSNumber* userID = mainUser.remoteId;
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