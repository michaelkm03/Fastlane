//
//  VMessageSubViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VKeyboardBarContainerViewController.h"
#import "VHasManagedDependencies.h"
#import "VAuthorizationContextProvider.h"

@class VDependencyManager, VUnreadMessageCountCoordinator, VConversation, ConversationDataSource;

@protocol VConversationContainerViewControllerDelegate <NSObject>

- (void)conversationFlaggedWithUserId:(NSNumber *)otherUserId;

@end

@interface VConversationContainerViewController : VKeyboardBarContainerViewController <VHasManagedDependencies, VAuthorizationContextProvider>

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, weak) id delegate;

@end
