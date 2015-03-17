//
//  VStreamCellFactory.h
//  victorious
//
//  Created by Josh Hinman on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VStreamItem;

/**
 Objects conforming to this protocol create and
 configure collection view cells for streams
 */
@protocol VStreamCellFactory <NSObject>

@required

/**
 Sends -registerClass:forCellWithReuseIdentifier: and -registerNib:forCellWithReuseIdentifier:
 messages to the collection view. Should be called as soon as the collection view is
 initialized.
 */
- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

/**
 Returns a cell configured to display a stream item
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the size of a cell for a specific stream item
 */
- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForStreamItem:(VStreamItem *)streamItem;

/**
 Returns the desired line spacing for cells from this factory
 */
- (CGFloat)minimumLineSpacing;

/**
 Returns the desired insets for sections containing cells from this factory
 */
- (UIEdgeInsets)sectionInsets;

@end
