//
//  VCollectionViewStreamFocusHelper.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamFocusHelper.h"

@interface VCollectionViewStreamFocusHelper : VAbstractStreamFocusHelper

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

- (void)updateCellFocus;
- (void)manuallyEndFocusOnCollectionViewCell:(UICollectionViewCell *)cell;

@end
