//
//  VObjectManager+Users.m
//  victorious
//
//  Created by Will Long on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"

@implementation VObjectManager (Users)

- (RKManagedObjectRequestOperation *)fetchUser:(NSNumber*)userId
                              withSuccessBlock:(SuccessBlock)success
                                     failBlock:(FailBlock)fail
{
    NSString* path = userId ? [NSString stringWithFormat:@"/api/userinfo/fetch/%@", userId] : @"/api/userinfo/fetch";

    return [self GET:path
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail
     paginationBlock:nil];
}

@end
