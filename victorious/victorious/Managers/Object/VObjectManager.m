//
//  VObjectManager.m
//  victorious
//
//  Created by Will Long on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "victorious-Swift.h"

#import "NSArray+VMap.h"
#import "VEnvironment.h"
#import "VErrorMessage.h"
#import "VObjectManager.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Login.h"
#import "VPaginationManager.h"
#import "VUploadManager.h"
#import "VRootViewController.h"
#import "VLocationManager.h"
#import "VConstants.h"
#import "NSString+VParseHelp.h"
#import "VUser+RestKit.h"
#import "VHashtag+RestKit.h"
#import "VSequence+RestKit.h"
#import "VComment+RestKit.h"
#import "VConversation+RestKit.h"
#import "VTracking+RestKit.h"
#import "VImageSearchResult.h"
#import "VPollResult+RestKit.h"
#import "VMessage+RestKit.h"
#import "VNotification+RestKit.h"
#import "VStream+RestKit.h"
#import "VNotificationSettings+RestKit.h"
#import "VEnvironmentManager.h"
#import "VObjectManager+ContentModeration.h"

static NSString * const kAlertsKey = @"alerts";

@import VictoriousCommon;
@import VictoriousIOSSDK;

#define EnableRestKitLogs 0 // Set to "1" to see RestKit logging, but please remember to set it back to "0" before committing your changes.

NS_ASSUME_NONNULL_BEGIN

@interface VObjectManager ()

@property (nonatomic, readwrite) VLoginType mainUserLoginType;
@property (nonatomic, strong, readwrite) VPaginationManager *paginationManager;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, readwrite) VUploadManager *uploadManager; ///< An object responsible for uploading files
@property (nonatomic, strong) AlertParser *alertParser;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString*, RKEntityMapping*> *mappingCache;

@end

@implementation VObjectManager

+ (void)setupObjectManagerWithUploadManager:(VUploadManager *__nonnull)uploadManager
{
#if DEBUG && EnableRestKitLogs
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
#warning RestKit logging is enabled. Please remember to disable it when you're done debugging.
#else
    RKLogConfigureByName("*", RKLogLevelOff);
#endif
    ;
    
    VEnvironment *currentEnvironment = [[VEnvironmentManager sharedInstance] currentEnvironment];
    VObjectManager *manager = [self managerWithBaseURL:currentEnvironment.baseURL];
    [manager.HTTPClient setDefaultHeader:@"Accept-Language" value:nil];
    manager.paginationManager = [[VPaginationManager alloc] initWithObjectManager:manager];
    manager.mappingCache = [[NSMutableDictionary alloc] init];
    
    uploadManager.objectManager = manager;
    manager.uploadManager = uploadManager;
    
    manager.alertParser = [[AlertParser alloc] init];
    manager.shouldRegisterAlerts = YES;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"victoriOS" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    manager.managedObjectStore = managedObjectStore;
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    [managedObjectStore addInMemoryPersistentStore:nil];
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    // This will allow us to call this manager with [RKObjectManager sharedManager]
    [self setSharedManager:manager];
    
    // This must be called AFTER we call setSharedManager as several of the entityDescriptions we add to our response descriptors call on the sharedManager
    [manager victoriousSetup];
    
    // Create an initial session ID
    [manager resetSessionID];
    
    [manager refreshFlaggedContents];
}

+ (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return dateFormatter;
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
    
    [self addResponseDescriptorsFromArray:[VUser descriptors]];
    [self addResponseDescriptorsFromArray:[VSequence descriptors]];
    [self addResponseDescriptorsFromArray:[VConversation descriptors]];
    [self addResponseDescriptorsFromArray:[VMessage descriptors]];
    [self addResponseDescriptorsFromArray:[VComment descriptors]];
    [self addResponseDescriptorsFromArray:[VNotification descriptors]];
    [self addResponseDescriptorsFromArray:[VStream descriptors]];
    [self addResponseDescriptorsFromArray:[VHashtag descriptors]];
    [self addResponseDescriptorsFromArray:[VNotificationSettings descriptors]];
    [self addResponseDescriptorsFromArray:[GIFSearchResult descriptors]];
    [self addResponseDescriptorsFromArray:[Experiment descriptors]];
    
    [self addResponseDescriptorsFromArray: @[errorDescriptor,
                                             verrorDescriptor,
                                             
                                             [VPollResult descriptor],
                                             [VPollResult createPollResultDescriptor],
                                             [VPollResult byUserDescriptor],
                                             [VTracking descriptor],
                                             [VImageSearchResult descriptor]
                                             ]];
    
    self.objectCache = [[NSCache alloc] init];
}

- (VUser *__nullable)mainUser
{
    NSAssert([NSThread isMainThread], @"mainUser should be accessed only from the main thread");
    return _mainUser;
}

#pragma mark - operation

- (RKManagedObjectRequestOperation *)requestMethod:(RKRequestMethod)method
                                            object:(id)object
                                              path:(NSString *)path
                                        parameters:(NSDictionary *)parameters
                                      successBlock:(VSuccessBlock)successBlock
                                         failBlock:(VFailBlock)failBlock
{
    NSURL *url = [NSURL URLWithString:path];
    if ([path isEmpty] || !url)
    {
        //Something has gone horribly wrong, so fail.
        if (failBlock)
        {
            failBlock(nil, nil);
        }
        return nil;
    }
    
    RKManagedObjectRequestOperation *requestOperation =
    [self  appropriateObjectRequestOperationWithObject:object method:method path:path parameters:parameters];
    
    void (^rkSuccessBlock) (RKObjectRequestOperation *, RKMappingResult *) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        NSMutableArray *mappedObjects = [mappingResult.array mutableCopy];
        VErrorMessage *error;
        for (id object in mappedObjects)
        {
            if ([object isKindOfClass:[VErrorMessage class]])
            {
                error = object;
                [mappedObjects removeObject:object];
                break;
            }
        }
        
        if ( error.errorCode == kVUnauthoizedError && self.mainUser )
        {
            [[[VUserManager alloc] init] logout];
            NSError *nsError = [NSError errorWithDomain:kVictoriousErrorDomain code:error.errorCode
                                               userInfo:@{NSLocalizedDescriptionKey:[error.errorMessages componentsJoinedByString:@","]}];
            if ( failBlock != nil )
            {
                failBlock( operation, nsError );
            }
        }
        else if (!error.errorCode && successBlock)
        {
            //Grab the response data, and make sure to process it... we must guarentee that the payload is a dictionary
            NSMutableDictionary *JSON = [[NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData
                                                                         options:0
                                                                           error:nil] mutableCopy];
            id payload = JSON[kVPayloadKey];
            if (payload && ![payload isKindOfClass:[NSDictionary class]])
            {
                JSON[kVPayloadKey] = @{@"objects":payload};
            }
            
            // Parse alerts payload
            id alerts = JSON[kAlertsKey];
            if (alerts != nil && [alerts isKindOfClass:[NSArray class]] && self.shouldRegisterAlerts && self.mainUser != nil)
            {
                [self.alertParser parseAlertsWithPayload:alerts];
            }
            
            successBlock(operation, JSON, mappedObjects);
        }
        else if (error.errorCode)
        {
            NSError *nsError = [NSError errorWithDomain:kVictoriousErrorDomain code:error.errorCode
                                               userInfo:@{NSLocalizedDescriptionKey:[error.errorMessages componentsJoinedByString:@","]}];
            [self defaultErrorHandlingForCode:nsError.code];
            
            if ( failBlock != nil )
            {
                failBlock( operation, nsError );
            }
        }
    };
    
    VFailBlock rkFailBlock = ^(NSOperation *operation, NSError *error)
    {
        RKErrorMessage *rkErrorMessage = [error.userInfo[RKObjectMapperErrorObjectsKey] firstObject];
        if ( rkErrorMessage.errorMessage.integerValue == kVUnauthoizedError )
        {
            // TODO: Create logout operation
            //[[[VUserManager alloc] init] logoutLocally];
        }
        else
        {
            [self defaultErrorHandlingForCode:rkErrorMessage.errorMessage.integerValue];
            
            if ( failBlock != nil )
            {
                failBlock( operation, error );
            }
        }
    };
    
    [requestOperation setCompletionBlockWithSuccess:rkSuccessBlock failure:rkFailBlock];
    [requestOperation start];
    return requestOperation;
}

- (void)defaultErrorHandlingForCode:(NSInteger)errorCode
{
    if ( errorCode == kVUpgradeRequiredError )
    {
        [[VRootViewController rootViewController] presentForceUpgradeScreen];
    }
    else if( errorCode == kVUserBannedError && self.mainUser )
    {
        // TODO: Create logout operation
        // [[[VUserManager alloc] init] logoutLocally];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserBannedTitle", @"")
                                                        message:NSLocalizedString(@"UserBannedMessage", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (RKManagedObjectRequestOperation *__nullable)GET:(NSString *)path
                                            object:(id __nullable)object
                                        parameters:(NSDictionary *__nullable)parameters
                                      successBlock:(VSuccessBlock __nullable)successBlock
                                         failBlock:(VFailBlock __nullable)failBlock
{
    return [self requestMethod:RKRequestMethodGET
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock];
}

- (RKManagedObjectRequestOperation *__nullable)POST:(NSString *)path
                                             object:(id __nullable)object
                                         parameters:(NSDictionary *__nullable)parameters
                                       successBlock:(VSuccessBlock __nullable)successBlock
                                          failBlock:(VFailBlock __nullable)failBlock
{
    return [self requestMethod:RKRequestMethodPOST
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock];
}

- (RKManagedObjectRequestOperation *__nullable)DELETE:(NSString *)path
                                               object:(id __nullable)object
                                           parameters:(NSDictionary *__nullable)parameters
                                         successBlock:(VSuccessBlock __nullable)successBlock
                                            failBlock:(VFailBlock __nullable)failBlock
{
    return [self requestMethod:RKRequestMethodDELETE
                        object:object
                          path:path
                    parameters:parameters
                  successBlock:successBlock
                     failBlock:failBlock];
}

- (AFHTTPRequestOperation *)uploadURLs:(NSDictionary *)allUrls
                                toPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                          successBlock:(VSuccessBlock)successBlock
                             failBlock:(VFailBlock)failBlock
{
    if ([path isEmpty])
    {
        //Something has gone horribly wrong, so fail.
        if (failBlock)
        {
            failBlock(nil, nil);
        }
        return nil;
    }
    
    NSMutableURLRequest *request =
    [self.HTTPClient multipartFormRequestWithMethod:@"POST"
                                               path:path
                                         parameters:parameters
                          constructingBodyWithBlock: ^(id <AFMultipartFormData>formData)
     {
         [allUrls enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
          {
              NSString *extension = [[obj pathExtension] lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
              if (extension)
              {
                  NSString *mimeType = [extension isEqualToString:VConstantMediaExtensionMOV] || [extension isEqualToString:VConstantMediaExtensionMP4]
                  ? @"video/quicktime" : @"image/png";
                  
                  [formData appendPartWithFileURL:obj
                                             name:key
                                         fileName:[key stringByAppendingPathExtension:extension]
                                         mimeType:mimeType
                                            error:nil];
              }
          }];
     }];
    
    [self updateHTTPHeadersInRequest:request];
    
    //Wrap the vsuccess block in a afsuccess block
    void (^afSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject)  = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError             *error                 = [self errorForResponse:responseObject];
        NSMutableDictionary *mutableResponseObject = [responseObject mutableCopy];
        
        id payload = mutableResponseObject[kVPayloadKey];
        if (payload && ![payload isKindOfClass:[NSDictionary class]])
        {
            mutableResponseObject[kVPayloadKey] = @{@"objects":payload};
        }
        
        if (!error && successBlock)
        {
            successBlock(operation, mutableResponseObject, @[]);
        }
        else
        {
            [self defaultErrorHandlingForCode:error.code];
            if (failBlock)
            {
                failBlock(operation, error);
            }
        }
    };
    
    AFHTTPRequestOperation *operation = [self.HTTPClient HTTPRequestOperationWithRequest:request
                                                                                 success:afSuccessBlock
                                                                                 failure:failBlock];
    [operation start];
    return operation;
}

- (NSError *)errorForResponse:(NSDictionary *)responseObject
{
    if ([responseObject[@"error"] integerValue] == 0)
    {
        return nil;
    }
    
    NSString *errorMessage = responseObject[@"message"];
    if ([errorMessage isKindOfClass:[NSArray class]])
    {
        errorMessage = [(NSArray *)errorMessage componentsJoinedByString:@", "];
    }
    
    return [NSError errorWithDomain:kVictoriousErrorDomain code:[responseObject[@"error"] integerValue]
                           userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}

- (NSManagedObject *__nullable)objectForID:(NSNumber *)objectID
                                     idKey:(NSString *)idKey
                                entityName:(NSString *)entityName
                      managedObjectContext:(NSManagedObjectContext *)context
{
    NSManagedObject *object = [self.objectCache objectForKey:[entityName stringByAppendingString:objectID.stringValue]];
    if (object)
    {
        return object;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"%K == %@", idKey, objectID];
    [request setPredicate:idFilter];
    NSError *error = nil;
    object = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
    }
    
    if (object)
    {
        [self.objectCache setObject:object forKey:[entityName stringByAppendingString:objectID.stringValue]];
    }
    
    return object;
}

- (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass
{
    NSAssert([NSThread isMainThread], @"This method must be called on the main thread");
    
    NSManagedObjectContext *context = [[self managedObjectStore] mainQueueManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    return [(NSManagedObject *)[subclass alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    return nil;
}

#pragma mark - Subclass

- (NSMutableURLRequest *)requestWithObject:(id)object
                                    method:(RKRequestMethod)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *urlRequest = [super requestWithObject:object method:method path:path parameters:parameters];
    [self updateHTTPHeadersInRequest:urlRequest];
    return urlRequest;
}

- (void)updateHTTPHeadersInRequest:(NSMutableURLRequest *)request
{
    __block NSInteger userID = 0;
    __block NSString *token = @"";
    
    // this may cause a deadlock if the main thread synchronously calls a background thread which then tries to initiate a networking call.
    // Can't think of a good reason why you'd ever do that, but still, beware.
    [self.managedObjectStore.mainQueueManagedObjectContext performBlockAndWait:^(void)
    {
        if ( self.mainUser.remoteId != nil && self.mainUser.token != nil )
        {
            userID = [self.mainUser.remoteId integerValue];
            token = self.mainUser.token;
        }
    }];
    
    [request v_setAuthenticationHeaderWithAppID:[[[VEnvironmentManager sharedInstance] currentEnvironment].appID integerValue]
                                       deviceID:[[UIDevice currentDevice].identifierForVendor UUIDString]
                                    buildNumber:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"]
                                         userID:userID
                            authenticationToken:token];

    [request v_setPlatformHeader];
    [request v_setOSVersionHeader];
    [request v_setAppVersionHeaderValue:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSString *experimentSettings = [[[ExperimentSettings alloc] init] commaSeparatedList];
    if ( experimentSettings != nil )
    {
        [request v_setExperimentsHeaderValue:experimentSettings];
    }
    
    FirstInstallDeviceIDManager *deviceIDManager = [[FirstInstallDeviceIDManager alloc] init];
    NSString *deviceID = [deviceIDManager generateFirstInstallDeviceIDWithFileName:[FirstInstallDeviceIDManager defaultDeviceIDFileName]];
    if ( deviceID != nil )
    {
        [request v_setIdentiferForVendorHeaderWithFirstInstallDeviceID:deviceID];
    }

    // Add location data to request if we have permission to collect it
    if ( [NSThread isMainThread] ) // locationManager can only be used from the main thread
    {
        VLocationManager *locationManager = [VLocationManager sharedInstance];
        if ( [VLocationManager haveLocationServicesPermission] && locationManager.location != nil )
        {
            [request v_setGeoLocationHeaderWithLocation:locationManager.location.coordinate postalCode:locationManager.locationPlacemark.postalCode];
        }
    }
    if ( self.sessionID != nil )
    {
        [request v_setSessionIDHeaderValue:self.sessionID];
    }
    
    NSString *locale = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    if ( locale != nil )
    {
        [request setValue:locale forHTTPHeaderField:@"Accept-Language"];
    }
}

- (void)resetSessionID
{
    self.sessionID = [[NSUUID UUID] UUIDString];
}

NS_ASSUME_NONNULL_END

@end
