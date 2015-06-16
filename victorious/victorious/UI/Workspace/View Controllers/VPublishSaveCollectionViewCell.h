//
//  VPublishSaveCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VDependencyManager;

/**
    A cell displaying a switch and a prompt.
 */
@interface VPublishSaveCollectionViewCell : VBaseCollectionViewCell

/**
    The size that would best fit this cell, given the collection view that will house it.
 
    @param collectionView The collection view that will house this cell
 
    @return The optimal size for this cell.
 */
+ (CGSize)desiredSizeInCollectionView:(UICollectionView *)collectionView;

@property (nonatomic, weak) IBOutlet UISwitch *cameraRollSwitch; ///< The switch displayed by this cell.
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependency manager used to style this cell.

@end
