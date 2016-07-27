//
//  VPaginatedDataSourceDelegate.h
//  victorious
//
//  Created by Josh Hinman on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VDataSourceState) {
    VDataSourceStateLoading,
    VDataSourceStateCleared,
    VDataSourceStateNoResults,
    VDataSourceStateResults,
    VDataSourceStateError,
};

@class PaginatedDataSource;

@protocol VPaginatedDataSourceDelegate <NSObject>

/// Called from a `PaginatedDataSource` instance when new objects have been fetched and added to its backing store.
/// The `oldValue` and `newValue` parameters are designed to allow calling code to
/// precisely reload only what has changed instead of using `reloadData()`.
- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue;

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didReceiveError:(NSError *)error;

@optional

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateStashedItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue;

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didPurgeVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue;

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didChangeStateFrom:(VDataSourceState)oldState to:(VDataSourceState)newState;

@end

NS_ASSUME_NONNULL_END
