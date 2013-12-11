//
//  VObjectManager+Private.h
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (Private)

- (RKManagedObjectRequestOperation *)GET:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(NSUInteger page, NSUInteger perPage, id result, NSError *error))block;
- (RKManagedObjectRequestOperation *)POST:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(NSUInteger page, NSUInteger perPage, id result, NSError *error))block;


- (RKManagedObjectRequestOperation *)GET:(NSString *)path
                              parameters:(NSDictionary *)parameters
                            successBlock:(SuccessBlock)successBlock
                               failBlock:(FailBlock)failBlock
                         paginationBlock:(PaginationBlock)paginationBlock;

- (RKManagedObjectRequestOperation *)POST:(NSString *)path
                               parameters:(NSDictionary *)parameters
                             successBlock:(SuccessBlock)successBlock
                                failBlock:(FailBlock)failBlock
                          paginationBlock:(PaginationBlock)paginationBlock;
@end
