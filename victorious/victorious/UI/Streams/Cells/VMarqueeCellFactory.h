//
//  VMarqueeCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStreamItem, VAbstractMarqueeCollectionViewCell;

@protocol VMarqueeCellFactory <NSObject>

@required

/**
 Sends -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
 messages to the collection view. Should be called as soon as the collection view is
 initialized.
 */
- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

/**
 Returns a configured marquee cell
 */
- (VAbstractMarqueeCollectionViewCell *)marqueeCellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the size of a cell for a specific stream item
 */
- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds;

/**
 Use this method to call enable timer on the marqueeController being managed by this factory
 */
- (void)enableTimer;

@property (nonatomic, weak) id delegate;

@end
