//
//  VMessageTableDataSource.h
//  victorious
//
//  Created by Josh Hinman on 8/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VConversation, VMessage, VMessageTableDataSource, VObjectManager, VUnreadMessageCountCoordinator, VUser;

@protocol VMessageTableDataDelegate <NSObject>

@required

/**
 Asks the delegate to provide a table cell for the given message at a specific index path.
 */
- (UITableViewCell *)dataSource:(VMessageTableDataSource *)dataSource cellForMessage:(VMessage *)message atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 Data source for private messaging.
 
 @discussion
 This class is not thread-safe. Only call its methods on the main thread.
 */
@interface VMessageTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak)     id<VMessageTableDataDelegate>  delegate;
@property (nonatomic, weak)     UITableView                   *tableView; ///< The tableView passed to the initializer
@property (nonatomic, strong)   VUser                         *otherUser; ///< The user with whom we are conversing
@property (nonatomic, readonly) VConversation                 *conversation; ///< Might be nil if we haven't yet sent or received any messages from this user.
@property (nonatomic, strong)   VObjectManager                *objectManager;
@property (nonatomic, strong)  VUnreadMessageCountCoordinator *messageCountCoordinator;

/**
 Creates a new instance of the receiver, adds it as the dataSource
 property of the given tableView, and registers reusable 
 conversation cells.
 
 @param objectManager an instance of VObjectManager used to perform network calls
 */
- (instancetype)initWithObjectManager:(VObjectManager *)objectManager;

- (void)refreshWithCompletion:(void(^)(NSError *error))completion; ///< Loads the latest messages from the server
- (void)loadNextPageWithCompletion:(void(^)(NSError *error))completion; ///< Loads the next page of messages from the server
- (BOOL)isLoading; ///< YES if we are currently waiting for a server operation to complete
- (BOOL)areMorePagesAvailable; ///< YES if more pages of data are available on the server
- (VMessage *)messageAtIndexPath:(NSIndexPath *)indexPath; ///< Returns the VMessage instance at the specified index path

/**
 Sends a new comment to the server and adds it to the table view
 */
- (void)createMessageWithText:(NSString *)text mediaURL:(NSURL *)mediaURL completion:(void(^)(NSError *))completion;

/**
 Starts a process that polls the server every few seconds for new messages
 */
- (void)beginLiveUpdates;

/**
 Stops polling the server for new messages.
 */
- (void)endLiveUpdates;

@end
