//
//  VObjectManagerV2.m
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VErrorMessage.h"
#import "VObjectManagerV2.h"
#import "VObjectManagerV2+Private.h"

#import "VConstants.h"

#import "NSString+SHA1Digest.h"

#import "VUser.h"

@interface VObjectManagerV2 ()

@property (nonatomic, strong) NSCache* objectCache;

@end

@implementation VObjectManagerV2

@synthesize mainUser;

+ (void)setupObjectManager
{
#if DEBUG
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#endif
    
    VObjectManagerV2 *manager = [self managerWithBaseURL:[NSURL URLWithString:VBASEURL]];
    
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
//                                             
//                                             [VUser descriptor],
//                                             [VCategory descriptor],
//                                             [VSequence sequenceListDescriptor],
//                                             [VSequence sequenceFullDataDescriptor],
//                                             [VSequence sequenceListPaginationDescriptor],
//                                             [VComment descriptor],
//                                             [VComment getAllDescriptor],
//                                             [VComment getAllPaginationDescriptor],
//                                             [VComment fetchDescriptor],
//                                             [VStatSequence gamesPlayedDescriptor],
//                                             [VStatSequence gameStatsDescriptor],
//                                             [VConversation descriptor],
//                                             [VMessage descriptor],
//                                             [VPollResult descriptor],
//                                             [VPollResult createPollResultDescriptor],
//                                             [VPollResult byUserDescriptor],
//                                             [VUnreadConversation descriptor]
                                             ]];
    
    _objectCache = [[NSCache alloc] init];
//    _paginationStatuses = [[NSMutableDictionary alloc] init];
}

#pragma mark - operation

- (RKManagedObjectRequestOperation *)requestMethod:(RKRequestMethod)method
                                            object:(id)object
                                              path:(NSString *)path
                                        parameters:(NSDictionary *)parameters
                                      successBlock:(VSuccessBlock)successBlock
                                         failBlock:(VFailBlock)failBlock
{
    RKManagedObjectRequestOperation *requestOperation =
        [self  appropriateObjectRequestOperationWithObject:object method:method path:path parameters:parameters];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         NSMutableArray* mappedObjects = [mappingResult.array mutableCopy];
         VErrorMessage* error = [mappedObjects firstObject];
         if(error && [error isKindOfClass:[VErrorMessage class]])
         {
             [mappedObjects removeObject:error];
         }
         
         if (error.errorCode && failBlock)
             failBlock(operation, [NSError errorWithDomain:kVictoriousDomain code:error.errorCode
                                       userInfo:@{NSLocalizedDescriptionKey: error.message}]);
         else if (successBlock)
             //TODO: pass back the full response object
             successBlock(operation, nil, mappedObjects);
     }
                                            //TODO: may need to wrap fail block to match RKFailBlock?
                                            failure:failBlock];
    
    [requestOperation start];
    return requestOperation;
}

- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                                  object:(id)object
                              parameters:(NSDictionary *)parameters
                            successBlock:(VSuccessBlock)successBlock
                               failBlock:(VFailBlock)failBlock
{
    return [self requestMethod:RKRequestMethodGET
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock];
}

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                                   object:(id)object
                               parameters:(NSDictionary *)parameters
                             successBlock:(VSuccessBlock)successBlock
                                failBlock:(VFailBlock)failBlock
{
    return [self requestMethod:RKRequestMethodPOST
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock];
}

- (AFHTTPRequestOperation*)upload:(NSDictionary*)allData
                    fileExtension:(NSDictionary*)allExtensions
                           toPath:(NSString*)path
                       parameters:(NSDictionary*)parameters
                     successBlock:(VSuccessBlock)successBlock
                        failBlock:(VFailBlock)failBlock
{
    [self updateHTTPHeadersForPath:path method:RKRequestMethodPOST];
    
    NSMutableURLRequest *request =
    [self.HTTPClient multipartFormRequestWithMethod:@"POST"
                                               path:path
                                         parameters:parameters
                          constructingBodyWithBlock: ^(id <AFMultipartFormData>formData)
     {
         [allData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
          {
              NSString* extension = allExtensions[key];
              if(extension)
              {
                  NSString* mimeType = [extension isEqualToString:VConstantMediaExtensionMOV]
                  ? @"video/quicktime" : @"image/png";
                  [formData appendPartWithFileData:obj
                                              name:key
                                          fileName:[key stringByAppendingPathExtension:extension]
                                          mimeType:mimeType];
              }
          }];
     }];
    
    //Wrap the vsuccess block in a afsuccess block
    void (^afSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject)  = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (successBlock)
            successBlock(operation, responseObject, nil);
    };
    
    AFHTTPRequestOperation *operation = [self.HTTPClient HTTPRequestOperationWithRequest:request
                                                                                 success:afSuccessBlock
                                                                                 failure:failBlock];
    [operation start];
    return operation;
}

#pragma mark - Subclass
- (id)appropriateObjectRequestOperationWithObject:(id)object
                                           method:(RKRequestMethod)method
                                             path:(NSString *)path
                                       parameters:(NSDictionary *)parameters
{
    [self updateHTTPHeadersForPath:path method:method];
    
    return [super appropriateObjectRequestOperationWithObject:object
                                                       method:method
                                                         path:path
                                                   parameters:parameters];
}

- (void)updateHTTPHeadersForPath:(NSString*)path method:(RKRequestMethod)method
{
    
    AFHTTPClient* client = [self HTTPClient];
    
    NSString *currentDate = [self rFC2822DateTimeString];
    NSString* userAgent = [client.defaultHeaders objectForKey:@"User-Agent"];
    
    NSString* token = self.mainUser.token ? self.mainUser.token : @"";
    
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
