//
//  VUnreadMessageCountCoordinator.m
//  victorious
//
//  Created by Josh Hinman on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUnreadMessageCountCoordinator.h"
#import "VObjectManager+DirectMessaging.h"

@interface VUnreadMessageCountCoordinator ()

@property (nonatomic, readwrite) NSInteger unreadMessageCount;
@property (nonatomic, readwrite) BOOL loadingUnreadMessageCount; ///< Are we waiting for the server to give us the unread message count?
@property (nonatomic, readwrite) BOOL shouldLoadUnreadMessageCountAgain; ///< If YES, when the current message count loading is done, do it again.
@property (nonatomic, strong) dispatch_queue_t privateQueue; ///< Synchronizes access to the two BOOL properties above.

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

- (void)updateUnreadMessageCount
{
    dispatch_async(self.privateQueue, ^(void)
    {
        if (self.loadingUnreadMessageCount)
        {
            self.shouldLoadUnreadMessageCountAgain = YES;
            return;
        }
        
        self.loadingUnreadMessageCount = YES;
        
        [self.objectManager unreadMessageCountWithCompletion:^(NSNumber *unreadMessages, NSError *error)
        {
            if ( unreadMessages != nil )
            {
                self.unreadMessageCount = [unreadMessages integerValue];
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

@end
