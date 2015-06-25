//
//  VContentThumbnailsDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A data source that drives a VContentThumbnailViewController, providing cells
 and other data in order to display the provided sequences.
 */
@interface VContentThumbnailsDataSource : NSObject <UICollectionViewDataSource>

/**
 Designated initializer requires an array of sequences to populate
 each of the collection view cells with.
 */
- (instancetype)initWithSequences:(NSArray *)sequences NS_DESIGNATED_INITIALIZER;

/**
 Call during initialization to allow this class to register the
 cells it intends to dequeue and vend back to the colleciton view.
 */
- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end
