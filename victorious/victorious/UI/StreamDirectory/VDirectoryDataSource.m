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
#import "VStream.h"

@interface VDirectoryDataSource()

@property (nonatomic) BOOL isLoading;

@end

@implementation VDirectoryDataSource

- (instancetype)initWithStream:(VStream *)stream
{
    self = [self init];
    if (self)
    {
        self.stream = stream;
    }
    return self;
}

- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.stream.streamItems objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem
{
    return [NSIndexPath indexPathForRow:[self.stream.streamItems indexOfObject:streamItem] inSection:0];
}

- (NSUInteger)count
{
    return self.stream.streamItems.count;
}

- (void)refreshWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    self.isLoading = YES;
    [[VObjectManager sharedManager] refreshStream:self.stream
                                     successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         if (successBlock)
         {
             successBlock();
         }
         self.isLoading = NO;
     }
                                        failBlock:^(NSOperation* operation, NSError* error)
     {
         if (failureBlock)
         {
             failureBlock(error);
         }
         self.isLoading = NO;
     }];
}

- (void)loadNextPageWithSuccess:(void (^)(void))successBlock failure:(void (^)(NSError *))failureBlock
{
    self.isLoading = YES;
    [[VObjectManager sharedManager] loadNextPageOfStream:self.stream
                                            successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         if (successBlock)
         {
             successBlock();
         }
         self.isLoading = NO;
     }
                                               failBlock:^(NSOperation* operation, NSError* error)
     {
         if (failureBlock)
         {
             failureBlock(error);
         }
         self.isLoading = NO;
     }];
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
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VDirectoryItemCell *cell;
//    if ([item isKindOfClass:[VStream class]])
//    {
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVStreamDirectoryItemCellName forIndexPath:indexPath];
//    }
    cell.streamItem = item;
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
