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

- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                          Data:(NSData*)data
                                mediaExtension:(NSString*)extension
                                    toSequence:(VSequence*)sequence
                                     andParent:(VComment*)parent
                                  successBlock:(AFSuccessBlock)success
                                     failBlock:(AFFailBlock)fail;


- (RKManagedObjectRequestOperation *)removeComment:(VComment*)comment
                                        withReason:(NSString*)removalReason
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)flagComment:(VComment*)comment
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)likeComment:(VComment*)comment
                                    successBlock:(SuccessBlock)success
                                       failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)dislikeComment:(VComment*)comment
                                       successBlock:(SuccessBlock)success
                                          failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)unvoteComment:(VComment*)comment
                                      successBlock:(SuccessBlock)success
                                         failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)readComments:(NSArray*)readComments
                                     successBlock:(SuccessBlock)success
                                        failBlock:(FailBlock)fail;
@end
