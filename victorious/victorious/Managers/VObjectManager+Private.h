//
//  VObjectManager+Private.h
//  victorious
//
//  Created by Will Long on 1/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VPaginationStatus;


@interface VObjectManager ()

@property (nonatomic, strong) NSMutableDictionary* paginationStatuses;
@property (nonatomic, strong) NSCache* objectCache;

@end

@interface VObjectManager (Private)

- (NSManagedObject*)objectForID:(NSNumber*)objectID
                          idKey:(NSString*)idKey
                     entityName:(NSString*)entityName;

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

/*! Uses multipartFormRestquest to upload media.
 * allData key:value must be NSString* parameterName:NSData* binaryData
 * allExtensions must have same keys are allData, values are NSString* fileExtension */
- (AFHTTPRequestOperation*)upload:(NSDictionary*)allData
                    fileExtension:(NSDictionary*)allExtensions
                           toPath:(NSString*)path
                       parameters:(NSDictionary*)parameters
                     successBlock:(VSuccessBlock)successBlock
                        failBlock:(VFailBlock)failBlock;

-(VPaginationStatus *)statusForKey:(NSString*)key;

@end
