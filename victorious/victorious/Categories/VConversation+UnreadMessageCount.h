//
//  VConversation+UnreadMessageCount.h
//  victorious
//
//  Created by Will Long on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversation.h"

@interface VConversation (UnreadMessageCount)

/**
 Finds unread messages within the conversation
 and marks them as read
 
 @return the number of messages marked as read
 */
- (NSInteger)markMessagesAsRead;

@end
