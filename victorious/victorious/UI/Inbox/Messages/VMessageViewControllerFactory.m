//
//  VMessageViewControllerFactory.m
//  victorious
//
//  Created by Josh Hinman on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessageContainerViewController.h"
#import "VMessageViewController.h"
#import "VMessageViewControllerFactory.h"
#import "VUser.h"

@interface VMessageViewControllerFactory ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSMutableDictionary *messageViewControllers;

@end

@implementation VMessageViewControllerFactory

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
        _messageViewControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (VMessageContainerViewController *)messageViewControllerForUser:(VUser *)user
{
    VMessageContainerViewController *messageViewController = self.messageViewControllers[user.remoteId];
    
    if ( messageViewController == nil )
    {
        messageViewController = [VMessageContainerViewController messageViewControllerForUser:user dependencyManager:self.dependencyManager];
        self.messageViewControllers[user.remoteId] = messageViewController;
    }
    
    [(VMessageViewController *)messageViewController.conversationTableViewController setShouldRefreshOnAppearance:YES];
    
    if ( self.unreadMessageCountCoordinator != nil )
    {
        messageViewController.messageCountCoordinator = self.unreadMessageCountCoordinator;
    }
    
    return messageViewController;
}

@end
