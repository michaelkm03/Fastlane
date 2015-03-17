//
//  VToolPicker.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

@protocol VToolPicker;

@class VTickerPickerViewController;

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPickerDelegate <NSObject>

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index;

@end

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPickerDataSource <UICollectionViewDataSource>

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

- (id)toolAtIndex:(NSInteger)index;

@end

/**
 *  VToolPicker describes a generalized protocol that can be used by tool picker classes.
 */
@protocol VToolPicker <NSObject>

@property (nonatomic, strong) id<VToolPickerDataSource> dataSource;
@property (nonatomic, strong) id<VToolPickerDelegate> delegate;
@property (nonatomic, readonly) id <VWorkspaceTool> selectedTool; ///< The currently selected tool, if any.
@property (nonatomic, copy) void (^onToolSelection)(id <VWorkspaceTool> selectedTool); ///< A block that is called whenever a new tool has been selected.

@end
