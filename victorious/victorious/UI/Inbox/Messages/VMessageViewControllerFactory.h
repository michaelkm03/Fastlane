//
//  VMessageViewControllerFactory.h
//  victorious
//
//  Created by Josh Hinman on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>

@class VUnreadMessageCountCoordinator, VMessageContainerViewController, VUser;

/**
 Creates new VMessageContainerViewController instances on demand and
 holds onto previous instances so they can be re-used, not for
 efficiency but out of necessity
 */
@interface VMessageViewControllerFactory : NSObject <VHasManagedDependencies>

/**
 If set, this coordinator will be provided to VMessageContainerViewController instances created by this class.
 */
@property (nonatomic, strong) VUnreadMessageCountCoordinator *unreadMessageCountCoordinator;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 Creates a VMessageViewController for conversing with the specified user,
 or returns the existing instance if one has been created previously.
 */
- (VMessageContainerViewController *)messageViewControllerForUser:(VUser *)user;

@end
