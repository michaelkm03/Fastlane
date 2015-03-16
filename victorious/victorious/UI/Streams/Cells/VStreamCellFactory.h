//
//  VStreamCellFactory.h
//  victorious
//
//  Created by Josh Hinman on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
 Returns a cell configured to display a sequence
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForSequence:(VSequence *)sequence atIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the size of a cell for a specific sequence
 */
- (CGSize)sizeWithCollectionViewBounds:(CGRect)bounds ofCellForSequence:(VSequence *)sequence;

/**
 Returns the desired space between cells
 */
- (CGFloat)minimumInteritemSpacing;

/**
 Returns the desired insets for sections containing cells from this factory
 */
- (UIEdgeInsets)sectionInsets;

@end
