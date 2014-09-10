//
//  VStreamTableDataSource.h
//  victorious
//
//  Created by Josh Hinman on 6/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VStream;

/**
 *  Posted whenever the underlying data source chages.
 */
UIKIT_EXTERN NSString *const VStreamTableDataSourceDidChangeNotification;

@class VSequence, VSequenceFilter, VStreamTableDataSource;

@protocol VStreamTableDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VStreamTableDataSource *)dataSource cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VStreamTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, weak)   id<VStreamTableDataDelegate>  delegate;
@property (nonatomic, weak)   UITableView                  *tableView; ///< The UITableView object to which the receiver is providing data
@property (nonatomic)         VStream                      *stream;    ///< Changing this property will send a -reloadData message to your table view

- (instancetype)initWithStream:(VStream*)stream;
- (VSequence *)sequenceAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSequence:(VSequence *)sequence;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
