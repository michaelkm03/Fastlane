//
//  VContentThumbnailsDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VContentThumbnailsDataSource : NSObject <UICollectionViewDataSource>

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end
