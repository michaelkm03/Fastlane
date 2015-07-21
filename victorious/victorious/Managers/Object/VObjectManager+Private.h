//
//  VObjectManager+Private.h
//  victorious
//
//  Created by Will Long on 1/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VLoginType.h"

@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface VObjectManager ()

@property (nonatomic, strong) NSCache *objectCache;
@property (nonatomic, strong, nullable) VUser *mainUser;
@property (nonatomic, assign) VLoginType loginType;

@end

@interface VObjectManager (Private)

- (NSManagedObject *__nullable)objectForID:(NSNumber *)objectID
                                     idKey:(NSString *)idKey
                                entityName:(NSString *)entityName
                      managedObjectContext:(NSManagedObjectContext *)context;

- (id)objectWithEntityName:(NSString *)entityName
                  subclass:(Class)subclass;

- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                                  object:(id __nullable)object
                              parameters:(NSDictionary *__nullable)parameters
                            successBlock:(VSuccessBlock __nullable)successBlock
                               failBlock:(VFailBlock __nullable)failBlock;

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                                   object:(id __nullable)object
                               parameters:(NSDictionary *__nullable)parameters
                             successBlock:(VSuccessBlock __nullable)successBlock
                                failBlock:(VFailBlock __nullable)failBlock;

- (RKManagedObjectRequestOperation *)DELETE:(NSString *)path
                                     object:(id __nullable)object
                                 parameters:(NSDictionary *__nullable)parameters
                               successBlock:(VSuccessBlock __nullable)successBlock
                                  failBlock:(VFailBlock __nullable)failBlock;

/*! Uses multipartFormRestquest to upload media.
 * allURLs key:value must be NSString *parameterName:NSURL *localURL
 * allExtensions must have same keys are allURLs, values are NSString *fileExtension */
- (AFHTTPRequestOperation *)uploadURLs:(NSDictionary *)allUrls
                                toPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                          successBlock:(VSuccessBlock)successBlock
                             failBlock:(VFailBlock)failBlock;

/**
 Sets the User-Agent, Authorization and Date headers in the given NSMutableURLRequest object
 */
- (void)updateHTTPHeadersInRequest:(NSMutableURLRequest *)request;

/**
 Invokes the default behaviors for the given victorious error code.
 Currently, that means displaying an alert for a banned user or
 presenting a forced upgrade screen.
 */
- (void)defaultErrorHandlingForCode:(NSInteger)errorCode;

/**
 Returns a string representation of the given object.
 If object is a string, it is returned. If object
 is an NSNumber, the results of calling -stringValue
 on that object are returned. For all other objects,
 the results of calling -description are returned.
 */
- (NSString *)stringFromObject:(id)object;

/**
 A date formatter configured for the server's format settings.
 This instance is not shared, so it can be modified freely by calling code.
 @return Configured NSDateFormatter instance.
 */
+ (NSDateFormatter *)dateFormatter;

NS_ASSUME_NONNULL_END

@end
