//
//  VStreamDirectoryDataSource.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamDirectoryDataSource.h"

#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"

@implementation VStreamDirectoryDataSource

- (instancetype)initWithFilter:(VAbstractFilter *)filter
{
    self = [self init];
    if (self)
    {
        self.filter = filter;
    }
    return self;
}

- (VAbstractFilter *)filterAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSIndexPath *)indexPathForFilter:(VAbstractFilter *)sequence
{
    return nil;
}

- (NSUInteger)count
{
    return 0;
}

- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    [[VObjectManager sharedManager] refres]
}

- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock
{
    
}

- (BOOL)isFilterLoading
{
    return [[[VObjectManager sharedManager] paginationManager] isLoadingFilter:self.filter];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
