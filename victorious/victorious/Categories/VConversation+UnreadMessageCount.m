//
//  VConversation+UnreadMessageCount.m
//  victorious
//
//  Created by Will Long on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+UnreadMessageCount.h"

#import "VMessage.h"

#import "VObjectManager.h"
#import "VUser.h"
#import "VUnreadConversation.h"

@implementation VConversation (UnreadMessageCount)

- (void)markMessagesAsRead
{
    NSInteger unreadMessages = 0;
    for (VMessage *message in  self.messages)
    {
        if (!message.isRead.boolValue)
        {
            unreadMessages++;
            message.isRead = @(YES);
            [message.managedObjectContext saveToPersistentStore:nil];
        }
    }
    
    NSManagedObjectID *objectId = [VObjectManager sharedManager].mainUser.unreadConversation.objectID;
    if (objectId)//Since the object may be nil.
    {
        VUnreadConversation *unreadCounts = (VUnreadConversation *)[self.managedObjectContext objectWithID:objectId];
        unreadCounts.count = @(unreadCounts.count.integerValue - unreadMessages);
        [self.managedObjectContext saveToPersistentStore:nil];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:MAX(unreadCounts.count.integerValue, 0)];
    }
}

@end
