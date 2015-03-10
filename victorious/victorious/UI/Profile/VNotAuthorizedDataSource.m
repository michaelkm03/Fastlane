//
//  VNotLoggedInProfileDataSource.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"

@interface VNotAuthorizedDataSource () <VNotAuthorizedProfileCollectionViewCellDelegate>

@end

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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNotAuthorizedProfileCollectionViewCell *notAuthorizedCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VNotAuthorizedProfileCollectionViewCell suggestedReuseIdentifier]
                                                                                                           forIndexPath:indexPath];
    notAuthorizedCell.delegate = self;
    return notAuthorizedCell;
}

#pragma mark - VNotAuthorizedProfileCollectionViewCellDelegate

- (void)notAuthorizedProfileCellWantsLogin:(VNotAuthorizedProfileCollectionViewCell *)cell
{
    [self.delegate dataSourceWantsAuthorization:self];
}

@end
