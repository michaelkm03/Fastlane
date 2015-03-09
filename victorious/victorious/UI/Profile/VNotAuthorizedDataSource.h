//
//  VNotLoggedInProfileDataSource.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A simple UICollecitonViewDataSource that populates the collectionview
 provided in its initializer with a single cell to inform the user they 
 are not currently authorized. Provides a block-based callback when the
 user requests authorization. 
 
 NOTE: UICollectionViewDelegate will not be altered. You can assume that
 the didSelectCellForIndexPath 0:0 is a request to login.
 */
@interface VNotAuthorizedDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
