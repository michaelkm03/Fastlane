//
//  VObjectManager+DirectMessaging.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Private.h"

#import "VMessage.h"
#import "VUser.h"

@implementation VObjectManager (DirectMessaging)

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)loadNextPageOfMessagesForConversation:(VConversation*)conversations
                                                              successBlock:(SuccessBlock)success
                                                                 failBlock:(FailBlock)fail
{
    return nil;
}

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation*)conversation
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail
{
    return [self POST:@"api/message/mark_conversation_read"
               object:nil
           parameters:@{@"conversations_id" : conversation.remoteId}
         successBlock:success
            failBlock:fail
      paginationBlock:nil];

}

- (RKManagedObjectRequestOperation *)sendMessageToUser:(VUser*)user
                                              withText:(NSString*)text
                                                  Data:(NSData*)data
                                        mediaExtension:(NSString*)extension
                                          successBlock:(SuccessBlock)success
                                             failBlock:(FailBlock)fail
{
    //Set the parameters
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:5];
    if (user)
        [parameters setObject:[NSString stringWithFormat:@"%@", user.remoteId] forKey:@"sequence_id"];
    if (text)
        [parameters setObject:text forKey:@"text"];
    if (data && extension)
    {
        [parameters setObject:data forKey:@"media_data"];
        [parameters setObject:extension forKey:@"media_type"];
    }
    
    NSString* path = [NSString stringWithFormat:@"api/message/send"];
    
    return [self POST:path
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

//Don't think we need this API call, but just in case...
- (RKManagedObjectRequestOperation *)unreadCountForConversation:(VConversation*)conversation
                                                   successBlock:(SuccessBlock)success
                                                      failBlock:(FailBlock)fail
{
    return nil;
}

@end
