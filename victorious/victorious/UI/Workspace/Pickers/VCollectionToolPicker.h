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

/**
 As the only class that knows about the cells being used for display,
 the method allows a collection view ask the data source to register those
 cells in order to be prepared for dequeuing and display.
 */
- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@optional

/**
 Reload the data that this data source provides, after which the completion callback
 will be called with an array of VWorkspaceTool objects to which loaded data has been
 marshalled.
 */
- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion;

@end

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VCollectionToolPicker <NSObject>

/**
 The collection view data source that loads and manages the data to display
 as well as configuring and supplying cells to display.
 */
@property (nonatomic, strong) id<VCollectionToolPickerDataSource> dataSource;

/**
 Reloads the collection view, which asks its data source for a fresh batch
 of configured cells.
 */
- (void)reloadData;

@end
