//
//  VConversation+UnreadMessageCount.m
//  victorious
//
//  Created by Will Long on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation+UnreadMessageCount.h"
#import "VMessage.h"

@implementation VConversation (UnreadMessageCount)

- (NSInteger)markMessagesAsRead
{
    NSInteger unreadMessages = 0;
    for (VMessage *message in self.messages)
    {
        if (!message.isRead.boolValue)
        {
            unreadMessages++;
            message.isRead = @(YES);
        }
    }
    return unreadMessages;
}

@end
