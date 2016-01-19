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

- (instancetype)initWithObjectManager:(VObjectManager *)objectManager
{
    self = [super init];
    if (self)
    {
        _objectManager = objectManager;
        _loadingUnreadMessageCount = 0;
        _privateQueue = dispatch_queue_create("VInboxCoordinator private queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
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
        [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
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

- (void)markConversationRead:(VConversation *)conversation
{
    if ( conversation.remoteId == nil )
    {
        return;
    }
    
    MarkConversationReadOperation *operation = [[MarkConversationReadOperation alloc] initWithConversationID:conversation.remoteId.integerValue];
    [operation queueOn:operation.defaultQueue completionBlock:^(NSError *_Nullable error)
    {
        if ( operation.unreadMessageCount != nil )
        {
            dispatch_async(self.privateQueue, ^(void)
            {
                if (self.loadingUnreadMessageCount)
                {
                    self.shouldLoadUnreadMessageCountAgain = YES;
                    return;
                }
                dispatch_sync(dispatch_get_main_queue(), ^(void)
                {
                    self.unreadMessageCount = operation.unreadMessageCount.integerValue;
                });
            });
        }
    }];
}

@end
