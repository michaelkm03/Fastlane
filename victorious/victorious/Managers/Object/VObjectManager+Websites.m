//
//  VObjectManager+Websites.m
//  victorious
//
//  Created by Will Long on 6/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+Websites.h"

#import "VObjectManager+Private.h"
#import "VConstants.h"

@implementation VObjectManager (Websites)

- (RKManagedObjectRequestOperation*)fetchToSWithCompletionBlock:(VWebsiteCompletion)completionBlock
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if (completionBlock)
        {
            NSString* htmlString = fullResponse[kVPayloadKey][@"html"];
            completionBlock(operation, htmlString, nil);
        }
    };
    
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
        if (completionBlock)
        {
            completionBlock(operation, nil, error);
        }
    };
    
    return [self GET:@"/api/tos" object:nil parameters:nil successBlock:success failBlock:fail];
}

@end
