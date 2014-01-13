//
//  VObjectManager+DirectMessaging.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"

#import "VConversation.h"

@interface VObjectManager (DirectMessaging)

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfMessagesForConversation:(VConversation*)conversation
                                                              successBlock:(SuccessBlock)success
                                                                 failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation*)conversation
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)sendMessageToUser:(VUser*)user
                                              withText:(NSString*)text
                                                  Data:(NSData*)data
                                        mediaExtension:(NSString*)extension
                                          successBlock:(SuccessBlock)success
                                             failBlock:(FailBlock)fail;

- (RKManagedObjectRequestOperation *)unreadCountForConversationsWithSuccessBlock:(SuccessBlock)success
                                                                       failBlock:(FailBlock)fail;
@end
