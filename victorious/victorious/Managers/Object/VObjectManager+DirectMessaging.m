//
//  VObjectManager+DirectMessaging.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Private.h"
#import "VObjectManager+Pagination.h"

#import "VMessage.h"
#import "VUser.h"

#import "VConversation+RestKit.h"
#import "VConversation+UnreadMessageCount.h"

static NSString * const kUnreadCountKey = @"unread_count";

@implementation VObjectManager (DirectMessaging)

- (RKManagedObjectRequestOperation *)conversationWithUser:(VUser *)user
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    NSParameterAssert(user != nil);
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id result, NSArray *resultObjects)
    {
        for (VConversation *conversation in resultObjects)
        {
            if (conversation.remoteId != nil)
            {
                conversation.filterAPIPath = [self apiPathForConversationWithRemoteID:conversation.remoteId];
            }
            conversation.user = user;
        };
        
        if (success)
        {
            success(operation, result, resultObjects);
        }
    };
    
    return [self GET:[@"/api/message/conversation_with_user/" stringByAppendingString:user.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)conversationByID:(NSNumber *)conversationID
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        for (VUser *user in resultObjects)
        {
            if ([user.remoteId isEqualToNumber:self.mainUser.remoteId])
            {
                continue;
            }
            
            [self conversationWithUser:user
                          successBlock:success
                             failBlock:fail];
        }
    };
    
    return [self GET:[@"/api/message/participants/" stringByAppendingString:conversationID.stringValue]
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation *)conversation
                                             withCompletion:(VUnreadMessageCountCompletionBlock)completion
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if ( completion != nil )
        {
            completion([self unreadMessageCountFromResponse:fullResponse], nil);
        }
    };
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        if (completion)
        {
            completion(nil, error);
        }
    };
    
    // Mark the most recent message as read so there is no server delay.
    conversation.isRead = @(YES);
    [conversation markMessagesAsRead];
    [conversation.managedObjectContext saveToPersistentStore:nil];
    
    return [self POST:@"/api/message/mark_conversation_read"
               object:nil
           parameters:@{@"conversation_id" : conversation.remoteId ?: [NSNull null]}
         successBlock:success
            failBlock:fail];
    
}

- (RKManagedObjectRequestOperation *)unreadMessageCountWithCompletion:(VUnreadMessageCountCompletionBlock)completion
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if ( completion != nil )
        {
            completion([self unreadMessageCountFromResponse:fullResponse], nil);
        }
    };
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        if (completion)
        {
            completion(nil, error);
        }
    };
    
    return [self GET:@"/api/message/unread_message_count"
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fail];
}

- (NSNumber *)unreadMessageCountFromResponse:(id)fullResponse
{
    if ( ![fullResponse isKindOfClass:[NSDictionary class]] )
    {
        return nil;
    }
    NSDictionary *payload = fullResponse[kVPayloadKey];
    
    if ( ![payload isKindOfClass:[NSDictionary class]] )
    {
        return nil;
    }
    
    NSNumber *unreadCount = payload[kUnreadCountKey];
    
    if ( [unreadCount isKindOfClass:[NSNumber class]] )
    {
        return unreadCount;
    }
    else
    {
        return nil;
    }
}

- (RKManagedObjectRequestOperation *)deleteConversation:(VConversation *)conversation
                                           successBlock:(VSuccessBlock)success
                                              failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/message/delete_conversation"
               object:nil
           parameters:@{@"conversation_id" : conversation.remoteId}
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)flagConversation:(VConversation *)conversation
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    if (!conversation)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return nil;
    }
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFlagConversation];
    
    VMessage *latestMessage = [conversation.messages lastObject];
    if (!latestMessage)
    {
        if (fail)
        {
            fail(nil, nil);
        }
        return nil;
    }
    
    return [self POST:@"/api/message/flag"
               object:nil
           parameters:@{ @"message_id" : latestMessage.remoteId }
         successBlock:success
            failBlock:fail];
}

@end
