//
//  VStreamDirectoryDataSource.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDirectoryDataSource, VAbstractFilter, VDirectory, VDirectoryItem;

@protocol VStreamDirectoryDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VDirectoryDataSource *)dataSource cellForItem:(VDirectoryItem *)item atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VDirectoryDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) id<VStreamDirectoryDataDelegate> delegate;
@property (nonatomic, strong) VAbstractFilter *filter;
@property (nonatomic, strong) VDirectory *directory;

- (instancetype)initWithDirectory:(VDirectory *)directory;

- (VDirectoryItem *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(VDirectoryItem *)directoryItem;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
