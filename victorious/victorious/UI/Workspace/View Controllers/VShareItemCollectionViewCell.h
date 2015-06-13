//
//  VShareItemCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VShareMenuItem;
@class VDependencyManager;

typedef NS_ENUM(NSInteger, VShareItemCellState)
{
    VShareItemCellStateSelected,
    VShareItemCellStateLoading,
    VShareItemCellStateUnselected
};

@interface VShareItemCollectionViewCell : VBaseCollectionViewCell

- (void)populateWithShareMenuItem:(VShareMenuItem *)menuItem andDependencyManager:(VDependencyManager *)dependencyManager;
- (void)setBorderColor:(UIColor *)borderColor;

@property (nonatomic, assign) VShareItemCellState state;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, readonly) VShareMenuItem *shareMenuItem;

@end
