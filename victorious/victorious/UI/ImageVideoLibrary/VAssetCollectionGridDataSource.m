//
//  VAssetCollectionGridDataSource.m
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionGridDataSource.h"

// Views + Helpers
#import "VAssetCollectionViewCell.h"
#import "NSIndexSet+Convenience.h"
#import "victorious-swift.h"

static NSInteger const kScreenSizeCacheTrigger = 1 / 3.0f;

@interface VAssetCollectionGridDataSource () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *fetchResultForAssetsToDisplay;
@property (nonatomic, assign) CGRect previousPrefetchRect;

@end

@implementation VAssetCollectionGridDataSource

#pragma mark - Lifecycle Methods

- (instancetype)initWithMediaType:(PHAssetMediaType)mediaType
{
    self = [super init];
    if (self != nil)
    {
        _mediaType = mediaType;
        _imageManager = [[PHCachingImageManager alloc] init];
        _itemsPerRow = 3;
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Property Accessors

- (void)setAssetCollection:(PHAssetCollection *)assetCollection
{
    if ([_assetCollection.localIdentifier isEqualToString:assetCollection.localIdentifier])
    {
        [self.collectionView reloadData];
        return;
    }
    _assetCollection = assetCollection;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithAssetMediaType:self.mediaType];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.fetchResultForAssetsToDisplay = [PHAsset fetchAssetsInAssetCollection:_assetCollection
                                                                       options:fetchOptions];
    
    // Reload and scroll to top
    [self.collectionView reloadData];
    if ([self.collectionView numberOfItemsInSection:0] > 0)
    {
        self.collectionView.contentOffset = CGPointZero;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)setItemsPerRow:(NSUInteger)itemsPerRow
{
    NSParameterAssert(itemsPerRow > 0);
    _itemsPerRow = itemsPerRow;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self handleChange:changeInstance];
                   });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResultForAssetsToDisplay.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VAssetCollectionViewCell suggestedReuseIdentifier]
                                                                               forIndexPath:indexPath];
    
    // Configure cell for asset
    cell.imageManager = self.imageManager;
    PHAsset *assetAtIndexPath = [self assetForIndexPath:indexPath];
    cell.asset = assetAtIndexPath;
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewFlowLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fullWidth = CGRectGetWidth(collectionView.bounds);
    CGFloat widthWithoutInsetAndPadding = fullWidth - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right - (2 * collectionViewLayout.minimumInteritemSpacing);
    CGFloat itemWidth = widthWithoutInsetAndPadding / self.itemsPerRow;
    return CGSizeMake(VFLOOR(itemWidth), VFLOOR(itemWidth));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate assetCollectionDataSource:self
                               selectedAsset:[self assetForIndexPath:indexPath]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - Private Methods

- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchResultForAssetsToDisplay objectAtIndex:indexPath.row];
}

- (CGSize)desiredImageSize
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = [self collectionView:self.collectionView
                                    layout:self.collectionView.collectionViewLayout
                    sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    return CGSizeMake(cellSize.width * scale, cellSize.height * scale);
}

#pragma mark - Caching

- (void)handleChange:(PHChange *)change
{
    // check if there are changes to the assets (insertions, deletions, updates)
    PHFetchResultChangeDetails *collectionChanges = [change changeDetailsForFetchResult:self.fetchResultForAssetsToDisplay];
    if (collectionChanges == nil)
    {
        return;
    }
    
    // get the new fetch result
    self.fetchResultForAssetsToDisplay = [collectionChanges fetchResultAfterChanges];
    
    UICollectionView *collectionView = self.collectionView;
    if (![collectionChanges hasIncrementalChanges])
    {
        // we need to reload all if the incremental diffs are not available
        [collectionView reloadData];
    }
    else
    {
        [self handleAdvancedpdatesWithChangeDetails:collectionChanges];
    }
    
    [self resetCachedAssets];
}

- (void)handleAdvancedpdatesWithChangeDetails:(PHFetchResultChangeDetails *)changeDetails
{
    // if we have incremental diffs, tell the collection view to animate insertions and deletions
    [self.collectionView performBatchUpdates:^
     {
         NSIndexSet *removedIndexes = [changeDetails removedIndexes];
         NSMutableIndexSet *safeDeletedIndexes = [[NSMutableIndexSet alloc] init];
         
         // Filter out indexes that are out of bounds
         [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
          {
              if (index < self.fetchResultForAssetsToDisplay.count)
              {
                  [safeDeletedIndexes addIndex:index];
              }
          }];
         
         if ([safeDeletedIndexes count] > 0)
         {
             [self.collectionView deleteItemsAtIndexPaths:[safeDeletedIndexes indexPathsFromIndexesWithSection:0]];
         }
         
         NSIndexSet *insertedIndexes = [changeDetails insertedIndexes];
         if ([insertedIndexes count] > 0)
         {
             [self.collectionView insertItemsAtIndexPaths:[insertedIndexes indexPathsFromIndexesWithSection:0]];
         }
         
         NSIndexSet *changedIndexes = [changeDetails changedIndexes];
         NSMutableIndexSet *safeChangedIndexes = [[NSMutableIndexSet alloc] init];
         
         // Filter out indexes that we've deleted to prevent crashing
         [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             if (![removedIndexes containsIndex:index])
             {
                 [safeChangedIndexes addIndex:index];
             }
         }];

         if ([safeChangedIndexes count] > 0)
         {
             [self.collectionView reloadItemsAtIndexPaths:[safeChangedIndexes indexPathsFromIndexesWithSection:0]];
         }
     } completion:NULL];
}


- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPrefetchRect = CGRectZero;
}

- (void)updateCachedAssets
{
    if (self.assetCollection == nil)
    {
        return;
    }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPrefetchRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) * kScreenSizeCacheTrigger)
    {
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPrefetchRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect)
         {
             NSArray *indexPaths = [self indexPathsInRect:removedRect];
             [removedIndexPaths addObjectsFromArray:indexPaths];
         }
                              addedHandler:^(CGRect addedRect)
         {
             NSArray *indexPaths = [self indexPathsInRect:addedRect];
             [addedIndexPaths addObjectsFromArray:indexPaths];
         }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:[self desiredImageSize]
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:[self desiredImageSize]
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPrefetchRect = preheatRect;
    }
}

- (NSArray *)indexPathsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes)
    {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect))
    {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY)
        {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY)
        {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY)
        {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY)
        {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    }
    else
    {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
    {
        return @[];
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        PHAsset *asset = self.fetchResultForAssetsToDisplay[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

@end
