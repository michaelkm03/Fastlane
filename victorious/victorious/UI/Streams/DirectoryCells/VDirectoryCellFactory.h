//
//  VDirectoryCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamCellFactory.h"

@class VDirectoryCollectionFlowLayout;

@protocol VDirectoryCellFactory <NSObject, VStreamCellFactory>

@required
/**
    @return A float representing the minimum space between cells
 */
- (CGFloat)minimumInterItemSpacing;

/**
    @return The collection view flow layout that will be used by the VDirectoryViewController's collection view
 */
- (VDirectoryCollectionFlowLayout *)collectionViewFlowLayout;

@optional

/**
    Called by VDirectoryViewController in collectionView:willDisplayCell:atIndexPath.
    Use this to adjust cell properties right before display.
 
    @param cell The collection view cell that is about to be displayed
    @param collectionView The collection view that is about to display the cell
    @param indexPath The index path where the cell will be displayed
 */
- (void)prepareCell:(UICollectionViewCell *)cell forDisplayInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
    Called by VDirectoryViewController in scrollViewDidScroll:
 
    @param collectionView The collection view that has just scrolled
 */
- (void)collectionViewDidScroll:(UICollectionView *)collectionView;

@end
