//
//  VContentThumbnailsDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@class VDependencyManager;

/**
 A data source that drives a VContentThumbnailViewController, providing cells
 and other data in order to display the provided sequences.
 */
@interface VContentThumbnailsDataSource : NSObject <UICollectionViewDataSource>

/**
 Creates a new data source with the provided collection view.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

/**
 Array of sequences to populate each of the collection view cells with.
 */
@property (nonatomic, strong) NSArray *sequences;

/**
 The dependency manager used to style cells returned from this data source.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
