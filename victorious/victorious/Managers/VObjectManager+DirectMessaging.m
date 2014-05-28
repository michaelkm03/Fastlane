//
//  VObjectManager+DirectMessaging.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Users.h"
#import "VObjectManager+Private.h"

#import "VMessage.h"
#import "VUser.h"

#import "VConstants.h"

#import "VConversation+RestKit.h"

@implementation VObjectManager (DirectMessaging)


- (RKManagedObjectRequestOperation *)conversationWithUser:(VUser*)user
                                             successBlock:(VSuccessBlock)success
                                                failBlock:(VFailBlock)fail
{
    for (VConversation* conversation in user.conversations)
    {
        if ([conversation.user.remoteId isEqualToNumber:user.remoteId])
        {
            if (success)
                success(nil, nil, @[conversation]);
            return nil;
        }
    }
    
    VFailBlock fullFail = ^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
        
        if (error.code == kVConversationDoesNotExistError)
        {
            VConversation *newConversation = [NSEntityDescription
                                              insertNewObjectForEntityForName:[VConversation entityName]
                                              inManagedObjectContext:self.managedObjectStore.persistentStoreManagedObjectContext];
            
            NSManagedObjectID* objectID = [user objectID];
            if (objectID)
            {
                VUser* userInContext = (VUser*)[newConversation.managedObjectContext objectWithID:objectID];
                
                newConversation.other_interlocutor_user_id = userInContext.remoteId;
                newConversation.user = userInContext;
            }
            
            [newConversation.managedObjectContext saveToPersistentStore:nil];
            
            if (success)
                success(nil, nil, @[newConversation]);
        }
        
        else if (fail)
            fail(operation, error);
    };
    
    return [self GET:[@"/api/message/conversation_with_user/" stringByAppendingString:user.remoteId.stringValue]
              object:nil
          parameters:nil
        successBlock:success
           failBlock:fullFail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail
{
    NSString* path = @"/api/message/conversation_list";
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSManagedObjectContext* context;
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VConversation* conversation in resultObjects)
        {
            //There should only be one message.  Its the current 'last message'
            conversation.lastMessage = [conversation.messages anyObject];
            
            //Sometimes we get -1 for the current logged in user
            if (!conversation.lastMessage.user && [conversation.lastMessage.senderUserId isEqual: @(-1)])
                conversation.lastMessage.user = self.mainUser;
            else if (!conversation.lastMessage.user)
                [nonExistantUsers addObject:conversation.lastMessage.senderUserId];
            
            if (!conversation.user)
                [nonExistantUsers addObject:conversation.other_interlocutor_user_id];
            
            context = conversation.managedObjectContext;
        }
        
        [context saveToPersistentStore:nil];
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfMessagesForConversation:(VConversation*)conversation
                                                              successBlock:(VSuccessBlock)success
                                                                 failBlock:(VFailBlock)fail
{
    if (!conversation)
    {
        if (fail)
            fail(nil, nil);
        return nil;
    }
    
    NSString* path = [@"/api/message/conversation/" stringByAppendingString:conversation.remoteId.stringValue];
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //TODO: send notif if we have new messages?
        conversation.messages = [NSSet set]; //TODO: this will need to change with pagination / messageIDs
        NSMutableArray* nonExistantUsers = [[NSMutableArray alloc] init];
        for (VMessage* message in resultObjects)
        {
            [conversation addMessagesObject:(VMessage*)[conversation.managedObjectContext objectWithID:[message objectID]]];
            
            //Sometimes we get -1 for the current logged in user
            if (!message.user && [message.senderUserId  isEqual: @(-1)])
                message.user = self.mainUser;
            else if (!message.user)
                [nonExistantUsers addObject:message.senderUserId];
        }
        
        [conversation.managedObjectContext saveToPersistentStore:nil];
        
        if ([nonExistantUsers count])
            [[VObjectManager sharedManager] fetchUsers:nonExistantUsers
                                      withSuccessBlock:success
                                             failBlock:fail];
        else if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation*)conversation
                                               successBlock:(VSuccessBlock)success
                                                  failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/message/mark_conversation_read"
               object:nil
           parameters:@{@"conversation_id" : conversation.remoteId ?: [NSNull null]}
         successBlock:success
            failBlock:fail];
    
}

- (RKManagedObjectRequestOperation *)unreadCountForConversationsWithSuccessBlock:(VSuccessBlock)success
                                                                       failBlock:(VFailBlock)fail
{
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        if ([resultObjects firstObject])
            self.mainUser.unreadConversation = (VUnreadConversation*)[self.mainUser.managedObjectContext objectWithID:[[resultObjects firstObject] objectID]];

        if (success)
            success(operation, fullResponse, resultObjects);
    };
    
    return [self GET:@"/api/message/unread_message_count"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail];
}

- (RKManagedObjectRequestOperation *) deleteConversation:(VConversation*)conversation
                                            successBlock:(VSuccessBlock)success
                                               failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/message/delete_conversation"
              object:conversation
           parameters:@{@"conversation_id" : conversation.remoteId}
        successBlock:success
           failBlock:fail];
}

@end
