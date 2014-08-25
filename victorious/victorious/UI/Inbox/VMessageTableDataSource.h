//
//  VMessageTableDataSource.h
//  victorious
//
//  Created by Josh Hinman on 8/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VMessageTableDataSource, VObjectManager, VUser;

@protocol VMessageTableDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VMessageTableDataSource *)dataSource cellForMessage:(VMessage *)message atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 Data source for private messaging.
 
 @discussion
 This class is not thread-safe. Only call its methods on the main thread.
 */
@interface VMessageTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak)   id<VMessageTableDataDelegate>  delegate;
@property (nonatomic, weak)   UITableView                   *tableView; ///< The tableView passed to the initializer
@property (nonatomic, strong) VUser                         *otherUser; ///< The user with whom we are conversing
@property (nonatomic, strong) VObjectManager                *objectManager;

/**
 Creates a new instance of the receiver, adds it as the dataSource
 property of the given tableView, and registers reusable 
 conversation cells.
 
 @param otherUser     the user with whom we are conversing
 @param objectManager an instance of VObjectManager used to perform network calls
 */
- (instancetype)initWithUser:(VUser *)otherUser objectManager:(VObjectManager *)objectManager;

- (void)refreshWithCompletion:(void(^)(NSError *error))completion;
- (void)loadNextPageWithCompletion:(void(^)(NSError *error))completion;
- (BOOL)isLoading;
- (BOOL)areMorePagesAvailable; ///< YES if more pages of data are available on the server
- (VMessage *)messageAtIndexPath:(NSIndexPath *)indexPath;

/**
 Starts a process that polls the server every few seconds for new messages
 */
- (void)beginLiveUpdates;

/**
 Stops polling the server for new messages.
 */
- (void)endLiveUpdates;

@end
