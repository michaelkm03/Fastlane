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

@interface VConversationContainerViewController : VKeyboardBarContainerViewController <VHasManagedDependencies, VAuthorizationContextProvider>

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic, strong) ConversationDataSource *dataSource;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;

+ (instancetype)messageViewControllerForConversation:(VConversation *)conversation dependencyManager:(VDependencyManager *)dependencyManager;

@end
