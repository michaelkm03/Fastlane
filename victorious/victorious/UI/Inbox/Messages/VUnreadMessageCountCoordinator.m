//
//  VUnreadMessageCountCoordinator.m
//  victorious
//
//  Created by Josh Hinman on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUnreadMessageCountCoordinator.h"
#import "victorious-Swift.h"

@interface VUnreadMessageCountCoordinator ()

@property (nonatomic, readwrite) NSInteger unreadMessageCount;
@property (nonatomic, readwrite) BOOL loadingUnreadMessageCount; ///< Are we waiting for the server to give us the unread message count?
@property (nonatomic, readwrite) BOOL shouldLoadUnreadMessageCountAgain; ///< If YES, when the current message count loading is done, do it again.

/**
 Synchronizes access to the two BOOL properties: loadingUnreadMessageCount and shouldLoadUnreadMessageCountAgain.
 
 WARNING: Do not dispatch on this queue synchronously from the main thread, or you might introduce a deadlock!
 */
@property (nonatomic, strong) dispatch_queue_t privateQueue;

@end

@implementation VUnreadMessageCountCoordinator

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _loadingUnreadMessageCount = 0;
        _privateQueue = dispatch_queue_create("VInboxCoordinator private queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)updateUnreadMessageCount
{
    if ([AgeGate isAnonymousUser])
    {
        return;
    }
    dispatch_async(self.privateQueue, ^(void)
    {
        if (self.loadingUnreadMessageCount)
        {
            self.shouldLoadUnreadMessageCountAgain = YES;
            return;
        }
        
        self.loadingUnreadMessageCount = YES;
        
        UnreadMessageCountOperation *operation = [[UnreadMessageCountOperation alloc] init];
        [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error)
         {
             if ( operation.unreadMessagesCount != nil )
             {
                 self.unreadMessageCount = operation.unreadMessagesCount.integerValue;
             }
            dispatch_async(self.privateQueue, ^(void)
            {
                self.loadingUnreadMessageCount = NO;
                if (self.shouldLoadUnreadMessageCountAgain)
                {
                    [self updateUnreadMessageCount];
                    self.shouldLoadUnreadMessageCountAgain = NO;
                }
            });
        }];
    });
}

- (void)markConversationRead:(VConversation *)conversation completion:(void(^)())completion
{
    if ( conversation.remoteId == nil || conversation.remoteId.integerValue == 0 )
    {
        if ( completion != nil )
        {
            completion();
        }
        return;
    }
    
    MarkConversationReadOperation *operation = [[MarkConversationReadOperation alloc] initWithConversationID:conversation.remoteId.integerValue];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error)
    {
        if ( operation.unreadConversationsCount != nil )
        {
            if (self.loadingUnreadMessageCount)
            {
                self.shouldLoadUnreadMessageCountAgain = YES;
                return;
            }
            self.unreadMessageCount = operation.unreadConversationsCount.integerValue;
        }
        if ( completion != nil )
        {
            completion();
        }
    }];
}

@end
