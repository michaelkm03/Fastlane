//
//  VContentThumbnailsDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUser;

@interface VContentThumbnailsDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithUser:(VUser *)user;

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView;

@end
