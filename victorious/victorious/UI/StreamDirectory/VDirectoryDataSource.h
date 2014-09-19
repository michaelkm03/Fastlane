//
//  VStreamDirectoryDataSource.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDirectoryDataSource, VAbstractFilter, VStream, VStreamItem;

@protocol VStreamDirectoryDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VDirectoryDataSource *)dataSource cellForItem:(VStreamItem *)item atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VDirectoryDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) id<VStreamDirectoryDataDelegate> delegate;
@property (nonatomic, strong) VAbstractFilter *filter;
@property (nonatomic, strong) VStream *stream;

- (instancetype)initWithStream:(VStream *)stream;

- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
