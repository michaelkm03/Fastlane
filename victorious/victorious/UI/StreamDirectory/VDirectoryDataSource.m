//
//  VStreamDirectoryDataSource.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryDataSource.h"

//UI
#import "VDirectoryItemCell.h"

//Managers
#import "VObjectManager+Pagination.h"
#import "VPaginationManager.h"

//Data Models
#import "VDirectory.h"
#import "VStream.h"

@implementation VDirectoryDataSource

- (instancetype)initWithDirectory:(VDirectory *)directory
{
    self = [self init];
    if (self)
    {
        self.directory = directory;
    }
    return self;
}

- (VDirectoryItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.directory.directoryItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForItem:(VDirectoryItem *)directoryItem
{
    return [NSIndexPath indexPathForRow:[self.directory.directoryItems indexOfObject:directoryItem] inSection:0];
}

- (NSUInteger)count
{
    return self.directory.directoryItems.count;
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
    VDirectoryItem *item = [self.directory.directoryItems objectAtIndex:indexPath.row];
    VDirectoryItemCell *cell;
//    if ([item isKindOfClass:[VStream class]])
//    {
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVStreamDirectoryItemCellName forIndexPath:indexPath];
//    }
    cell.directoryItem = item;
    return cell;
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
