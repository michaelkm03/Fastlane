//
//  VObjectManager+Discover.m
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Discover.h"
#import "VObjectManager+Private.h"
#import "VUser.h"

@implementation VObjectManager (Discover)

- (RKManagedObjectRequestOperation *)getSuggestedUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/discover/users"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)getSuggestedHashtags:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self GET:@"/api/discover/hashtags"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

@end
