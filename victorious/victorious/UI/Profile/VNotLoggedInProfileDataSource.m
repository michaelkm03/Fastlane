//
//  VNotLoggedInProfileDataSource.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotLoggedInProfileDataSource.h"
#import "VNotLoggedInProfileCollectionViewCell.h"

@implementation VNotLoggedInProfileDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        [collectionView registerNib:[VNotLoggedInProfileCollectionViewCell nibForCell]
         forCellWithReuseIdentifier:[VNotLoggedInProfileCollectionViewCell suggestedReuseIdentifier]];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:[VNotLoggedInProfileCollectionViewCell suggestedReuseIdentifier]
                                                     forIndexPath:indexPath];
}

@end
