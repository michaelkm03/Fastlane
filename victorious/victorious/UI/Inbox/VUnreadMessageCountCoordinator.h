//
//  VUnreadMessageCountCoordinator.h
//  victorious
//
//  Created by Josh Hinman on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VObjectManager;

/**
 This class coordinates updates to the global
 unread message count from multiple view 
 controllers and/or threads
 */
@interface VUnreadMessageCountCoordinator : NSObject

@property (nonatomic, readonly) VObjectManager *objectManager; ///< An instance of VObjectManager used to make API calls
@property (nonatomic, readonly) NSInteger unreadMessageCount; ///< The total number of unread messages. KVO-compliant.

/**
 Initializes an instance of VInboxCoordinator
 
 @param objectManager an instance of VObjectManager for making API calls
 */
- (instancetype)initWithObjectManager:(VObjectManager *)objectManager NS_DESIGNATED_INITIALIZER;

/**
 Asynchronously retrieves the current unread message 
 count from the server. Get the result by key-value
 observing the unreadMessageCount property.
 */
- (void)updateUnreadMessageCount;

@end
