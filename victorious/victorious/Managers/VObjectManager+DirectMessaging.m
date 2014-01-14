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

@implementation VObjectManager (DirectMessaging)

- (void)testSendMessage
{
    for (int i=0; i <5; i++)
    {
        [[self sendMessageToUser:nil
                        withText:[NSString stringWithFormat: @"Test %i", i]
                            Data:nil
                  mediaExtension:nil
                    successBlock:nil
                       failBlock:nil] start];
    }
}

- (RKManagedObjectRequestOperation *)loadNextPageOfConversations:(SuccessBlock)success
                                                       failBlock:(FailBlock)fail
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
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects){
        
        for (VConversation* conversation in resultObjects)
        {
            //There should only be one message.  Its the current 'last message'
            conversation.lastMessage = [conversation.messages anyObject];
            [conversation.managedObjectContext save:nil];
            
            if (!conversation.user )
            {
                //If we don't have the users then we need to fetch em.
                [[self fetchUser:conversation.other_interlocutor_user_id
           forRelationshipObject:conversation
                withSuccessBlock:nil
                       failBlock:nil] start];
            }
        }
        
        if (success)
            success(resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail
     paginationBlock:nil];//pagination];
}

- (RKManagedObjectRequestOperation *)loadNextPageOfMessagesForConversation:(VConversation*)conversation
                                                              successBlock:(SuccessBlock)success
                                                                 failBlock:(FailBlock)fail
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
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects)
    {
        for (VMessage* message in resultObjects)
        {
            [conversation addMessagesObject:(VMessage*)[conversation.managedObjectContext objectWithID:[message objectID]]];
            [conversation.managedObjectContext save:nil];
            if (!message.user )
            {
                //If we don't have the users then we need to fetch em.
                [[self fetchUser:message.senderUserId
           forRelationshipObject:message
                withSuccessBlock:nil
                       failBlock:nil] start];
            }
        }
        
        if (success)
            success(resultObjects);
    };
    
    return [self GET:path
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail
     paginationBlock:nil];//pagination];
}

- (RKManagedObjectRequestOperation *)markConversationAsRead:(VConversation*)conversation
                                               successBlock:(SuccessBlock)success
                                                  failBlock:(FailBlock)fail
{
    return [self POST:@"/api/message/mark_conversation_read"
               object:nil
           parameters:@{@"conversation_id" : conversation.remoteId}
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

    [parameters setObject:[NSString stringWithFormat:@"%@", user.remoteId] forKey:@"to_user_id"];
    
    if (text)
        [parameters setObject:text forKey:@"text"];
    if (data && extension)
    {
        [parameters setObject:data forKey:@"media_data"];
        [parameters setObject:extension forKey:@"media_type"];
    }
    
    NSString* path = [NSString stringWithFormat:@"/api/message/send"];
    
    return [self POST:path
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail
      paginationBlock:nil];
}

//Don't think we need this API call, but just in case...
- (RKManagedObjectRequestOperation *)unreadCountForConversationsWithSuccessBlock:(SuccessBlock)success
                                                                       failBlock:(FailBlock)fail
{
    
    SuccessBlock fullSuccess = ^(NSArray* resultObjects)
    {
        if ([resultObjects firstObject])
            self.mainUser.unreadConversation = (VUnreadConversation*)[self.mainUser.managedObjectContext objectWithID:[[resultObjects firstObject] objectID]];

        if (success)
            success(resultObjects);
    };
    
    return [self GET:@"/api/message/unread_message_count"
              object:nil
          parameters:nil
        successBlock:fullSuccess
           failBlock:fail
     paginationBlock:nil];
}

@end
