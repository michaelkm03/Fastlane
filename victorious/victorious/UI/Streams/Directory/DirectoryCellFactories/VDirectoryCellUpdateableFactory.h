//
//  VDirectoryCellUpdateableFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/**
    Classes that conform to this protocol will update cells based on the state
        of the collection view containing them.
 */
@protocol VDirectoryCellUpdeatableFactory <NSObject>

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END

@end
