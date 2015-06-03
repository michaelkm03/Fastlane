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

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VNotAuthorizedDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView dependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self != nil)
    {
        _dependencyManager = dependencyManager;
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
    notAuthorizedCell.dependencyManager = self.dependencyManager;
    return notAuthorizedCell;
}

#pragma mark - VNotAuthorizedProfileCollectionViewCellDelegate

- (void)notAuthorizedProfileCellWantsLogin:(VNotAuthorizedProfileCollectionViewCell *)cell
{
    [self.delegate dataSourceWantsAuthorization:self];
}

@end
