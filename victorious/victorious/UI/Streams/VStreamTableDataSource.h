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
extern NSString *const VStreamTableDataSourceDidChangeNotification;

@class VSequence, VSequenceFilter, VAbstractFilter, VStreamTableDataSource;

@protocol VStreamTableDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VStreamTableDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath;

@end

@interface VStreamTableDataSource : NSObject <UITableViewDataSource>

@property (nonatomic) BOOL shouldDisplayMarquee;///<If set to YES it will insert a section at index 0 with 1 row for the Marquee stream.

@property (nonatomic, weak)   id<VStreamTableDataDelegate>  delegate;
@property (nonatomic, weak)   UITableView                  *tableView; ///< The UITableView object to which the receiver is providing data
@property (nonatomic)         VStream                      *stream;    ///< Changing this property will send a -reloadData message to your table view
@property (nonatomic, readonly) VAbstractFilter            *filter;    ///< Filter associated with the stream object.  Changing the stream object changes this property

- (instancetype)initWithStream:(VStream *)stream;
- (VSequence *)sequenceAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSequence:(VSequence *)sequence;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
