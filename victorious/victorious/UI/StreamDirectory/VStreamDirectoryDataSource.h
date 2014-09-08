//
//  VStreamDirectoryDataSource.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VStreamDirectoryDataSource, VAbstractFilter;

@protocol VStreamDirectoryDataDelegate <NSObject>

@required
- (UITableViewCell *)dataSource:(VStreamDirectoryDataSource *)dataSource cellForFilter:(VAbstractFilter*)filter atIndexPath:(NSIndexPath *)indexPath;

@end

@interface VStreamDirectoryDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) id<VStreamDirectoryDataDelegate> delegate;
@property (nonatomic, strong) VAbstractFilter *filter;

- (instancetype)initWithFilter:(VAbstractFilter *)filter;
- (VAbstractFilter *)filterAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForFilter:(VAbstractFilter *)sequence;
- (NSUInteger)count;
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
