//
//  VStreamTableDataSource.h
//  victorious
//
//  Created by Josh Hinman on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence, VSequenceFilter, VStreamTableDataSource;

@protocol VStreamTableDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VStreamTableDataSource *)dataSource cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VStreamTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak)   id<VStreamTableDataDelegate>  delegate;
@property (nonatomic, weak)   UITableView                  *tableView; ///< The UITableView object to which the receiver is providing data

/**
 Setting this might change the data provided by the receiver. 
 Best to send a -reloadData message to your table view.
 */
@property (nonatomic) VSequenceFilter *filter;

- (instancetype)initWithFilter:(VSequenceFilter *)filter;
- (VSequence *)sequenceAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSequence:(VSequence *)sequence;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;

@end
