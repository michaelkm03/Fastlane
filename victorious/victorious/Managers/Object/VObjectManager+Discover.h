//
//  VObjectManager+Discover.h
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@interface VObjectManager (Discover)

- (RKManagedObjectRequestOperation *)getSuggestedUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)getSuggestedHashtags:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

@end