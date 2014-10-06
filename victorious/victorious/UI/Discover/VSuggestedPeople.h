//
//  VSuggestedPeople.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This is essentially a UICollectionViewController, but because the view is created
 and configured in the XIB of a table view cell, this class is not subclasses UICollectionViewController.
 */
@interface VSuggestedPeople : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
