//
//  VDirectoryCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamCellFactory.h"

@class VStreamItem, VStream, VDependencyManager, VDirectoryCollectionFlowLayout;

@protocol VDirectoryCellFactory <NSObject, VStreamCellFactory>

@required

- (CGFloat)minimumInterItemSpacing;

- (VDirectoryCollectionFlowLayout *)collectionViewFlowLayout;

@optional

- (void)prepareCell:(UICollectionViewCell *)cell forDisplayInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

- (void)collectionViewDidScroll:(UICollectionView *)collectionView;

@end
