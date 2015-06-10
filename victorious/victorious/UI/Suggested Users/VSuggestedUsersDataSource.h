//
//  VSuggesedUsersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VHasManagedDependencies.h"

@interface VSuggestedUsersDataSource : NSObject <UICollectionViewDataSource, VHasManagedDependencies>

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView;

- (void)refreshWithCompletion:(void(^)())completion;

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
