//
//  VCommentTableDataSource.h
//  victorious
//
//  Created by Will Long on 8/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VComment, VCommentFilter, VCommentTableDataSource;

@protocol VCommentTableDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VCommentTableDataSource *)dataSource cellForComment:(VComment *)comment atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VCommentTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak)   id<VCommentTableDataDelegate>  delegate;
@property (nonatomic, weak)   UITableView                  *tableView; ///< The UITableView object to which the receiver is providing data
@property (nonatomic)         VCommentFilter              *filter;    ///< Changing this property will send a -reloadData message to your table view

- (instancetype)initWithFilter:(VCommentFilter *)filter;
- (VComment *)commentAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForComment:(VComment *)comment;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;

@end
