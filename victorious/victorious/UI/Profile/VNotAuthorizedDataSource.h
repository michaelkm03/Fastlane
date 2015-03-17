//
//  VNotLoggedInProfileDataSource.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VNotAuthorizedDataSource;

/**
 *  A delegate informing about a request for login.
 */
@protocol VNotAuthorizedDataSourceDelegate <NSObject>

/**
 *  Informs the receiver that the user requested a login.
 */
- (void)dataSourceWantsAuthorization:(VNotAuthorizedDataSource *)dataSource;

@end

/**
 A simple UICollecitonViewDataSource that populates the collectionview
 provided in its initializer with a single cell to inform the user they 
 are not currently authorized. Provides a block-based callback when the
 user requests authorization. 
 
 NOTE: UICollectionViewDelegate will not be altered. You can assume that
 the didSelectCellForIndexPath 0:0 is a request to login.
 */
@interface VNotAuthorizedDataSource : NSObject <UICollectionViewDataSource>

/**
 *  The designated initializer for this class. Registers any cells required 
 *  by this data source.
 *  
 *  Note: The collection view dataSource and delegate properties are left 
 *  untouched in this method and the collection view is not retained.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

/**
 *  A delegate conforming to VNotAuthorizedDataSourceDelegate.
 */
@property (nonatomic, weak) id <VNotAuthorizedDataSourceDelegate> delegate;

@end
