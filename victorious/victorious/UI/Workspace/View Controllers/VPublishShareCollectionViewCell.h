//
//  VPublishShareCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VShareItemCollectionViewCell, VDependencyManager;

@protocol VPublishShareCollectionViewCellDelegate <NSObject>

/**
    Called when a share item cell is selected.
 
    @param shareItemCell The selected share item cell.
 */
- (void)shareCollectionViewSelectedShareItemCell:(VShareItemCollectionViewCell *)shareItemCell;

@end

/**
    A collection view cell that displays a prompt and an array of share item cells.
 */
@interface VPublishShareCollectionViewCell : VBaseCollectionViewCell

/**
    The optimal size for this cell given the collection view that will house it
    and the dependency manager containing the share items that this cell will display.
 
    @param collectionView The collectionView that will house this cell.
    @param dependencyManager A dependency manager containing share menu items that this cell will display.
 
    @return The optimal size for this cell.
 */
+ (CGSize)desiredSizeInCollectionView:(UICollectionView *)collectionView andDependencyManager:(VDependencyManager *)dependencyManager;

/**
    A dependency manager containing share menu items.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
    The delegate that will recieve messages for share selection events.
 */
@property (nonatomic, weak) id <VPublishShareCollectionViewCellDelegate> delegate;

/**
    The share types of all selected share menu item cells that this cell is displaying.
 */
@property (nonatomic, readonly) NSIndexSet *selectedShareTypes;

@end
