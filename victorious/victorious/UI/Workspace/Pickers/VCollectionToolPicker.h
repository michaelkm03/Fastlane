//
//  VCollectionToolPicker.h
//  victorious
//
//  Created by Patrick Lynch on 4/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VToolPicker.h"

@protocol VCollectionToolPicker, VMultipleToolPickerDelegate;

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VCollectionToolPickerDataSource <UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *tools;

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VCollectionToolPicker <NSObject>

@property (nonatomic, strong) id<VCollectionToolPickerDataSource> dataSource;

- (void)reloadData;

@end
