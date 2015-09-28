//
//  VContentThumbnailCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"
#import "VStreamCellSpecialization.h"

@class VStreamItem, VDependencyManager;

/**
 A collection view cell that shows an image fitted to the bounds of the cell
 with aspect fill.
 */
@interface VContentThumbnailCell : VBaseCollectionViewCell

- (void)setImage:(UIImage *)image animated:(BOOL)animated;

@end
