//
//  VNotLoggedInProfileDataSource.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotAuthorizedDataSource.h"
#import "VNotAuthorizedProfileCollectionViewCell.h"

@interface VNotAuthorizedDataSource ()

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

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VNotAuthorizedProfileCollectionViewCell *notAuthorizedCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VNotAuthorizedProfileCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
    notAuthorizedCell.dependencyManager = self.dependencyManager;
    return notAuthorizedCell;
}

@end
