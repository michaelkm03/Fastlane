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

-(VPaginationStatus *)statusForKey:(NSString*)key;

@end
