//
//  VObjectManager+Private.h
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"
#import "VPaginationStatus.h"

@interface VObjectManager ()

@property (nonatomic, strong) NSMutableDictionary* paginationStatuses;
@property (nonatomic, strong) NSMutableDictionary* userRelationships;

@end

@interface VObjectManager (Private)

- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                                  object:(id)object
                              parameters:(NSDictionary *)parameters
                            successBlock:(SuccessBlock)successBlock
                               failBlock:(FailBlock)failBlock
                         paginationBlock:(PaginationBlock)paginationBlock;

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                                   object:(id)object
                               parameters:(NSDictionary *)parameters
                             successBlock:(SuccessBlock)successBlock
                                failBlock:(FailBlock)failBlock
                          paginationBlock:(PaginationBlock)paginationBlock;

/*! Uses multipartFormRestquest to upload media.
 * allData key:value must be NSString* parameterName:NSData* binaryData
 * allExtensions must have same keys are allData, values are NSString* fileExtension */
- (AFHTTPRequestOperation*)upload:(NSDictionary*)allData
                    fileExtension:(NSDictionary*)allExtensions
                           toPath:(NSString*)path
                       parameters:(NSDictionary*)parameters
                     successBlock:(AFSuccessBlock)successBlock
                        failBlock:(AFFailBlock)failBlock;

-(VPaginationStatus *)statusForKey:(NSString*)key;

@end
