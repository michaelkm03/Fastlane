//
//  VNotLoggedInProfileDataSource.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"

@implementation VNotAuthorizedDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self)
    {
        [collectionView registerNib:[VNotAuthorizedProfileCollectionViewCell nibForCell]
         forCellWithReuseIdentifier:[VNotAuthorizedProfileCollectionViewCell suggestedReuseIdentifier]];
    }
    return self;
}

#pragma mark - Property Accessors



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:[VNotAuthorizedProfileCollectionViewCell suggestedReuseIdentifier]
                                                     forIndexPath:indexPath];
}

@end
