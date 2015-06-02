//
//  VObjectManager+VTemplateDownloaderConformance.m
//  victorious
//
//  Created by Josh Hinman on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager+Login.h"
#import "VObjectManager+VTemplateDownloaderConformance.h"

@implementation VObjectManager (VTemplateDownloaderConformance)

- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion
{
    NSParameterAssert(completion != nil);
    [self templateWithSuccessBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&jsonError];
        completion(jsonData, jsonError);
    }
                         failBlock:^(NSOperation *operation, NSError *error)
    {
        completion(nil, error);
    }];
}

@end
