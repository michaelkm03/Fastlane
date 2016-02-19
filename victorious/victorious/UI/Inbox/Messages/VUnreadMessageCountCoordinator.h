//
//  VUnreadMessageCountCoordinator.h
//  victorious
//
//  Created by Josh Hinman on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VConversation;

NS_ASSUME_NONNULL_BEGIN

/**
 This class coordinates updates to the global
 unread message count from multiple view 
 controllers and/or threads
 */
@interface VUnreadMessageCountCoordinator : NSObject

@property (nonatomic, readonly) NSInteger unreadMessageCount; ///< The total number of unread messages. KVO-compliant.

/**
 Asynchronously retrieves the current unread message 
 count from the server. Get the result by key-value
 observing the unreadMessageCount property.
 */
- (void)updateUnreadMessageCount;

/**
 Marks a conversation as read and updates the unreadMessageCount property asynchronously
 */
- (void)markConversationRead:(VConversation *)conversation completion:(void(^)())completion;

@end

NS_ASSUME_NONNULL_END
