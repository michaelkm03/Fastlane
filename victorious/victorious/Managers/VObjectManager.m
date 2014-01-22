//
//  VObjectManager.m
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VErrorMessage.h"
#import "VObjectManager.h"
#import "VObjectManager+Private.h"

#import "VConstants.h"

#import "NSString+SHA1Digest.h"

#import "VUser+RestKit.h"
#import "VSequence+RestKit.h"
#import "VCategory+RestKit.h"
#import "VComment+RestKit.h"
#import "VConversation+RestKit.h"
#import "VPollResult+RestKit.h"
#import "VMessage+RestKit.h"
#import "VUnreadConversation+RestKit.h"

#import "VPaginationStatus.h"

@implementation VObjectManager

@synthesize mainUser;

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
                                             [VSequence sequenceListPaginationDescriptor],
                                             [VComment descriptor],
                                             [VComment getAllDescriptor],
                                             [VComment getAllPaginationDescriptor],
                                             [VComment fetchDescriptor],
                                             [VConversation descriptor],
                                             [VMessage descriptor],
                                             [VPollResult descriptor],
                                             [VPollResult createPollResultDescriptor],
                                             [VPollResult byUserDescriptor],
                                             [VUnreadConversation descriptor]
                                             ]];
    
    self.objectCache = [[NSCache alloc] init];
    self.paginationStatuses = [[NSMutableDictionary alloc] init];
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
         {
             NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:0 error:nil];
             successBlock(operation, JSON, mappedObjects);
         }
     }
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

-(VPaginationStatus *)statusForKey:(NSString*)key
{
    VPaginationStatus* status = [self.paginationStatuses objectForKey:key];
    if (!status)
    {
        status = [[VPaginationStatus alloc] init];
    }
    
    return status;
}

- (NSManagedObject*)objectForID:(NSNumber*)objectID
                          idKey:(NSString*)idKey
                     entityName:(NSString*)entityName
{
    NSManagedObject* object = [self.objectCache objectForKey:[entityName stringByAppendingString:objectID.stringValue]];
    if (object)
        return object;
    
    NSManagedObjectContext* context = self.managedObjectStore.persistentStoreManagedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate* idFilter = [NSPredicate predicateWithFormat:@"%K == %@", idKey, objectID];
    [request setPredicate:idFilter];
    NSError *error = nil;
    object = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
    }
    
    if (object)
        [self.objectCache setObject:object forKey:[entityName stringByAppendingString:objectID.stringValue]];
    
    return object;
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
