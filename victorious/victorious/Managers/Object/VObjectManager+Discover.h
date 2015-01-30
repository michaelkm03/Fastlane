//
//  VObjectManager+Discover.h
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VAbstractFilter+RestKit.h"

@class VHashtag;

@interface VObjectManager (Discover)

- (RKManagedObjectRequestOperation *)getSuggestedUsers:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)getSuggestedHashtags:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)getHashtagsSubscribedToWithPageType:(VPageType)pageType
                                                            successBlock:(VSuccessBlock)success
                                                               failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unsubscribeToHashtagUsingVHashtagObject:(VHashtag *)hashtag
                                                                successBlock:(VSuccessBlock)success
                                                                   failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unsubscribeToHashtag:(NSString *)hashtag
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)subscribeToHashtagUsingVHashtagObject:(VHashtag *)hashtag
                                                              successBlock:(VSuccessBlock)success
                                                                 failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)subscribeToHashtag:(NSString *)hashtag
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)findHashtagsBySearchString:(NSString *)hashtag
                                                   successBlock:(VSuccessBlock)success
                                                      failBlock:(VFailBlock)fail;

@end
