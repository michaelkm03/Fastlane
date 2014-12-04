//
//  VObjectManager+DirectMessaging.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

@class VConversation;

typedef void (^VUnreadMessageCountCompletionBlock)(NSNumber *unreadMessages, NSError *error);

@interface VObjectManager (DirectMessaging)

- (RKManagedObjectRequestOperation *)conversationWithUser:(VUser *)user
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)conversationByID:(NSNumber *)conversationID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation *)conversation
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unreadMessageCountWithCompletion:(VUnreadMessageCountCompletionBlock)completion;

- (RKManagedObjectRequestOperation *)deleteConversation:(VConversation *)conversation
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)flagConversation:(VConversation *)conversation
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail;

@end
