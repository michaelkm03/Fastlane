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

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView;

- (void)refreshWithCompletion:(void(^)())completion;

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
