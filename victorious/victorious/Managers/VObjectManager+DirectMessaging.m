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

#import "VConversation+RestKit.h"

@implementation VObjectManager (DirectMessaging)

- (VConversation*)conversationWithUser:(VUser*)user
{
    //TODO: rethink this.  Another user has multiple conversations but can only have one conversation with you?
    for (VConversation* conversation in user.conversations)
    {
        if ([conversation.user.remoteId isEqualToNumber:user.remoteId])
            return conversation;
    }
    
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
    
    return newConversation;
}

- (void)testSendMessage
{
    for (int i=0; i <5; i++)
    {
        [self sendMessageToUser:nil
                       withText:[NSString stringWithFormat: @"Test %i", i]
                           Data:nil
                 mediaExtension:nil
                       mediaUrl:nil
                   successBlock:nil
                      failBlock:nil] ;
    }
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(VSuccessBlock)success
                                                       failBlock:(VFailBlock)fail
{
    NSString* path = @"/api/message/conversation_list";
    
    //    static NSString* kConversationPaginationKey = @"conversations";
    //    __block VPaginationStatus* status = [self statusForKey:kConversationPaginationKey];
    //    if([status isFullyLoaded])
    //    {
    //        return nil;
    //    }
    //
    //    if (status.pagesLoaded) //only add page to the path if we've looked it up before.
    //    {
    //        path = [path stringByAppendingFormat:@"/0/%lu/%lu", status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
    //    }
    //
    //    PaginationBlock pagination = ^(NSUInteger page_number, NSUInteger page_total)
    //    {
    //        status.pagesLoaded = page_number;
    //        status.totalPages = page_total;
    //        [self.paginationStatuses setObject:status forKey:kConversationPaginationKey];
    //    };
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        //Warning: Sometimes empty payloads will appear as Array objects. Use the following line at your own risk.
        //NSDictionary* payload = fullResponse[@"payload"];
        
        for (VConversation* conversation in resultObjects)
        {
            //There should only be one message.  Its the current 'last message'
            conversation.lastMessage = [conversation.messages anyObject];

            [conversation.managedObjectContext save:nil];
            
            if (!conversation.user )
            {
                //If we don't have the users then we need to fetch em.
                [self fetchUser:conversation.other_interlocutor_user_id
                withSuccessBlock:nil
                       failBlock:nil];
            }
        }
        
        if (success)
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
    NSString* path = [NSString stringWithFormat:@"/api/message/conversation/%@", conversation.remoteId];
    
//    NSString* statusKey = [NSString stringWithFormat:@"messagesFor%@", conversation.remoteId];
//    
//    __block VPaginationStatus* status = [self statusForKey:statusKey];
//    if([status isFullyLoaded])
//    {
//        return nil;
//    }
//    
//    if (status.pagesLoaded) //only add page to the path if we've looked it up before.
//    {
//        path = [path stringByAppendingFormat:@"/0/%lu/%lu", status.pagesLoaded + 1, (unsigned long)status.itemsPerPage];
//    }
//    
//    PaginationBlock pagination = ^(NSUInteger page_number, NSUInteger page_total)
//    {
//        status.pagesLoaded = page_number;
//        status.totalPages = page_total;
//        [self.paginationStatuses setObject:status forKey:statusKey];
//    };
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        for (VMessage* message in resultObjects)
        {
            [conversation addMessagesObject:(VMessage*)[conversation.managedObjectContext objectWithID:[message objectID]]];
            [conversation.managedObjectContext save:nil];
            if (!message.user )
            {
                //If we don't have the users then we need to fetch em.
                [self fetchUser:message.senderUserId
                withSuccessBlock:nil
                       failBlock:nil];
            }
        }
        
        if (success)
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
           parameters:@{@"conversation_id" : conversation.remoteId}
         successBlock:success
            failBlock:fail];
    
}

- (AFHTTPRequestOperation *)sendMessageToUser:(VUser*)user
                                     withText:(NSString*)text
                                         Data:(NSData*)data
                               mediaExtension:(NSString*)extension
                                     mediaUrl:(NSURL*)mediaUrl
                                 successBlock:(VSuccessBlock)success
                                    failBlock:(VFailBlock)fail
{
    //Set the parameters
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithCapacity:5];

    [parameters setObject:[NSString stringWithFormat:@"%@", user.remoteId] forKey:@"to_user_id"];
    
    if (text)
        [parameters setObject:text forKey:@"text"];
    
    NSDictionary *allData, *allExtensions;
    if (data && extension)
    {
        allData = @{@"media_data":data};
        allExtensions = @{@"media_data":extension};
    }
    
    return [self upload:allData
          fileExtension:allExtensions
                 toPath:@"/api/message/send"
             parameters:parameters
           successBlock:success
              failBlock:fail];
}

//Don't think we need this API call, but just in case...
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

@end
