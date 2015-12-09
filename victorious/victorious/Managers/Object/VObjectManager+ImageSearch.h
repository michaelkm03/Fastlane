//
//  VObjectManager+ImageSearch.h
//  victorious
//
//  Created by Josh Hinman on 5/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (ImageSearch)

/**
 Perform an image search on the server. The items in the success block
 will be instances of VImageSearchResult
 */
- (RKManagedObjectRequestOperation *)imageSearchWithKeyword:(NSString *)keyword
                                                 pageNumber:(NSUInteger)page
                                               itemsPerPage:(NSUInteger)perPage
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

@end
