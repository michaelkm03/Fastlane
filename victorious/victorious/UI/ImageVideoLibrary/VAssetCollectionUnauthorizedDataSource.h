//
//  VAssetCollectionUnauthorizedDataSource.h
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@class VAssetCollectionUnauthorizedDataSource;

/**
 *  A delegate for the data source.
 */
@protocol VAssetCollectionUnauthorizedDataSourceDelegate <NSObject>

/**
 *  Informs the delegate that the authorization has changed.
 */
- (void)unauthorizedDataSource:(VAssetCollectionUnauthorizedDataSource *)dataSource
        authorizationChangedTo:(BOOL)authorizationStatus;

@end

@interface VAssetCollectionUnauthorizedDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 *  The designated initializer for this data source.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  The delegate for this data source.
 */
@property (nonatomic, weak) id <VAssetCollectionUnauthorizedDataSourceDelegate> delegate;

@end
