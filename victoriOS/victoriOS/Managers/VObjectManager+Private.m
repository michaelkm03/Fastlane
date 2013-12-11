//
//  VObjectManager+Private.m
//  victoriOS
//
//  Created by David Keegan on 12/10/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager+Private.h"

@implementation VObjectManager (Private)

+ (RKManagedObjectRequestOperation *)requestMethod:(RKRequestMethod)method path:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(id result, NSError *error))block
{
    RKManagedObjectRequestOperation *requestOperation =
    [[self sharedManager] appropriateObjectRequestOperationWithObject:nil method:method path:path parameters:parameters];

    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if(block){
            if([[mappingResult firstObject] isKindOfClass:[RKErrorMessage class]]){
                RKErrorMessage *errorMessage = (RKErrorMessage *)[mappingResult firstObject];
                // TODO: create better error object
                block(nil, [NSError errorWithDomain:@"com.getvictorious.victoriOS" code:0
                                           userInfo:@{NSLocalizedDescriptionKey: errorMessage.errorMessage}]);
            }else{
                block(mappingResult, nil);
            }
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        if(block){
            block(nil, error);
        }
    }];

    return requestOperation;
}

+ (RKManagedObjectRequestOperation *)POST:(NSString *)path parameters:(NSDictionary *)parameters block:(void(^)(id result, NSError *error))block
{
    return [self requestMethod:RKRequestMethodPOST path:path parameters:parameters block:block];
}

@end
