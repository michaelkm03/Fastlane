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

- (VConversation*)conversationWithUser:(VUser*)user;

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)loadNextPageOfMessagesForConversation:(VConversation*)conversation
                                                              successBlock:(VSuccessBlock)success
                                                                 failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation*)conversation
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation *)sendMessageToUser:(VUser*)user
                                     withText:(NSString*)text
                                     mediaURL:(NSURL*)mediaURL
                                 successBlock:(VSuccessBlock)success
                                    failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)unreadCountForConversationsWithSuccessBlock:(VSuccessBlock)success
                                                                       failBlock:(VFailBlock)fail;

@end
