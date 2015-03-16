//
//  VToolPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@protocol VToolPickerDataSource <UICollectionViewDataSource>

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end