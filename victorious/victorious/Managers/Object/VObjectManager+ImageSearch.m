//
//  VObjectManager+ImageSearch.m
//  victorious
//
//  Created by Josh Hinman on 5/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+ImageSearch.h"
#import "VObjectManager+Private.h"
#import "NSCharacterSet+VURLParts.h"

@implementation VObjectManager (ImageSearch)

- (RKManagedObjectRequestOperation *)imageSearchWithKeyword:(NSString *)keyword
                                                 pageNumber:(NSUInteger)page
                                               itemsPerPage:(NSUInteger)perPage
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    NSString *path = [NSString stringWithFormat:@"/api/image/search/%@/%lu/%lu",
                        RKPercentEscapedQueryStringFromStringWithEncoding(keyword, NSUTF8StringEncoding),
                        (long)page,
                        (long)perPage];
    NSString *escapedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
    return [self GET:escapedPath
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail];
}

@end
