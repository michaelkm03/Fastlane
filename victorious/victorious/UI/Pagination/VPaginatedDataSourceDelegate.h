//
//  VPaginatedDataSourceDelegate.h
//  victorious
//
//  Created by Josh Hinman on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

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
/// precisely reload only what has changed instead of useing `reloadData()`.
- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue;

@optional

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didChangeStateFrom:(VDataSourceState)oldState to:(VDataSourceState)newState;

@end
