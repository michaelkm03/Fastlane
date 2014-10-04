//
//  VSuggestedPeople.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSuggestedPeople : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
