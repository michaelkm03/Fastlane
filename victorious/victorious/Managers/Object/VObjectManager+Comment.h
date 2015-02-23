//
//  VObjectManager+Comment.h
//  victoriOS
//
//  Created by Will Long on 12/13/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VObjectManager.h"

#import "VComment.h"

@interface VObjectManager (Comment)

- (RKManagedObjectRequestOperation *)fetchFiltedRealtimeCommentForAssetId:(NSInteger)assetId
                                                           successBlock:(VSuccessBlock)success
                                                              failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)fetchCommentByID:(NSInteger)commentID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)removeComment:(VComment *)comment
                                        withReason:(NSString *)removalReason
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)editComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)flagComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;

#pragma mark - Vote Methods
- (RKManagedObjectRequestOperation *)likeComment:(VComment *)comment
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)dislikeComment:(VComment *)comment
                                       successBlock:(VSuccessBlock)success
                                          failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unvoteComment:(VComment *)comment
                                      successBlock:(VSuccessBlock)success
                                         failBlock:(VFailBlock)fail;

@end
