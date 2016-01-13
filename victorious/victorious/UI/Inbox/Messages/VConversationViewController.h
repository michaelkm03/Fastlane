//
//  VConversationViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNoContentView.h"
#import <UIKit/UIKit.h>

@class VMessageTableDataSource, VUnreadMessageCountCoordinator, VUser, ConversationDataSource;

@interface VConversationViewController : UITableViewController <VHasManagedDependencies>

@property (nonatomic, strong) VConversation *conversation;
@property (nonatomic, strong) VUnreadMessageCountCoordinator *messageCountCoordinator;
@property (nonatomic, assign) UIEdgeInsets focusAreaInset;
@property (nonatomic, strong) ConversationDataSource *dataSource;
@property (nonatomic, strong) VNoContentView *noContentView;

/**
 Creates a new instance of VConversationViewController by passing in an instance of VDependencyManager
 */
+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
