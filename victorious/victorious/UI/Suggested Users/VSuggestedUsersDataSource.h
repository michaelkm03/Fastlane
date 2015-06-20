//
//  VSuggesedUsersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VHasManagedDependencies.h"

/**
 Data source for a collection view designed to display suggested users.  Loads users
 from the suggested users end point and creates and configures the suggested users
 cells that will be displayed in the collection view.
 */
@interface VSuggestedUsersDataSource : NSObject <UICollectionViewDataSource, VHasManagedDependencies>

/**
 Allows the datasource to register the cells it intends to use on the collection
 view into which it will be plugged.
 */
- (void)registerCellsForCollectionView:(UICollectionView *)collectionView;

/**
 Reload the data and call completion block when complete, regardless of success or fail.
 */
- (void)refreshWithCompletion:(void(^)())completion;

/**
 Designed to be forwarded from the collection view delegate, allows the data source
 (who is the keeper of the cells being used) to calculate the size bsed on the cell
 and that data it contains.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
