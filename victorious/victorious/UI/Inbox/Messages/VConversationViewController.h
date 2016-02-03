//
//  VConversationViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VNoContentView.h"
#import "VTimerManager.h"

@class VUnreadMessageCountCoordinator, VUser, VConversation, ConversationDataSource;

@interface VConversationViewController : UITableViewController <VHasManagedDependencies>

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, assign) UIEdgeInsets focusAreaInset;
@property (nonatomic, strong) ConversationDataSource *dataSource;
@property (nonatomic, strong) VNoContentView *noContentView;
@property (nonatomic, strong) VTimerManager *timer;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, assign) BOOL isLoadingNextPage;

/**
 Creates a new instance of VConversationViewController by passing in an instance of VDependencyManager
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
