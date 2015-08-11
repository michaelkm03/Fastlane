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

/**
    Classes that conform to this protocol will provide information
        regarding the spacing and layout of directory cells.
 */
@protocol VDirectoryCellFactory <NSObject, VStreamCellFactory>

NS_ASSUME_NONNULL_BEGIN

/**
    @return A float representing the minimum space between cells
 */
- (CGFloat)minimumInterItemSpacing;

/**
    @return The collection view flow layout that will be used by the VDirectoryViewController's collection view
 */
- (VDirectoryCollectionFlowLayout *__nullable)collectionViewFlowLayout;

NS_ASSUME_NONNULL_END

@end
