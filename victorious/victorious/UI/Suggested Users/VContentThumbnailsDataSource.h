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

- (instancetype)initWithSequences:(NSArray *)sequences NS_DESIGNATED_INITIALIZER;

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end
