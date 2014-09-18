//
//  VObjectManager+Private.h
//  victorious
//
//  Created by Will Long on 1/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager ()

@property (nonatomic, strong) NSCache *objectCache;
@property (nonatomic, strong) VUser  *mainUser;

@end

@interface VObjectManager (Private)

- (NSManagedObject *)objectForID:(NSNumber *)objectID
                          idKey:(NSString *)idKey
                     entityName:(NSString *)entityName
           managedObjectContext:(NSManagedObjectContext *)context;

- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                                  object:(id)object
                              parameters:(NSDictionary *)parameters
                            successBlock:(VSuccessBlock)successBlock
                               failBlock:(VFailBlock)failBlock;

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                                   object:(id)object
                               parameters:(NSDictionary *)parameters
                             successBlock:(VSuccessBlock)successBlock
                                failBlock:(VFailBlock)failBlock;

- (RKManagedObjectRequestOperation *)DELETE:(NSString *)path
                                     object:(id)object
                                 parameters:(NSDictionary *)parameters
                               successBlock:(VSuccessBlock)successBlock
                                  failBlock:(VFailBlock)failBlock;

/*! Uses multipartFormRestquest to upload media.
 * allURLs key:value must be NSString *parameterName:NSURL *localURL
 * allExtensions must have same keys are allURLs, values are NSString *fileExtension */
- (AFHTTPRequestOperation *)uploadURLs:(NSDictionary *)allUrls
                               toPath:(NSString *)path
                           parameters:(NSDictionary *)parameters
                         successBlock:(VSuccessBlock)successBlock
                            failBlock:(VFailBlock)failBlock;

@end
