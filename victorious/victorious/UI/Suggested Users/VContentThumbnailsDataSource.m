//
//  VContentThumbnailsDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentThumbnailsDataSource.h"
#import "VSequence+Fetcher.h"
#import "VContentThumbnailCell.h"
#import "VImageAsset.h"
#import "VImageAssetFinder.h"
#import "UIImage+Resize.h"

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) VImageAssetFinder *assetFinder;

@end

@implementation VContentThumbnailsDataSource

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        _assetFinder = [[VImageAssetFinder alloc] init];
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[self class]]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<UICollectionViewDelegateFlowLayout> delegate = (id<UICollectionViewDelegateFlowLayout>)collectionView.delegate;
    CGSize cellSize = [delegate collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    VContentThumbnailCell *cell = (VContentThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ( cell != nil )
    {
        VSequence *sequence = self.sequences[ indexPath.row ];
        VImageAsset *asset = [self.assetFinder assetWithPreferredMaximumSize:cellSize fromAssets:sequence.previewAssets];
        NSURL *imageURL = [NSURL URLWithString:asset.imageURL];
        __weak typeof(cell) weakCell = cell;
        [self loadImageWith:imageURL withSize:cellSize completion:^(UIImage *image, BOOL didDownload)
         {
             [weakCell setImage:image animated:didDownload];
         }];
        return cell;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sequences.count;
}

- (NSCache *)cache
{
    static NSCache *_cache;
    if ( _cache == nil )
    {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}

- (void)loadImageWith:(NSURL *)imageURL withSize:(CGSize)size completion:(void(^)(UIImage *image, BOOL didDownload))completion
{
    NSParameterAssert( completion != nil );
    
    static dispatch_queue_t resizeQueue;
    if ( resizeQueue == nil )
    {
        resizeQueue = dispatch_queue_create( "com.victorious.suggestedUsersResizeQueue", DISPATCH_QUEUE_CONCURRENT );
    }
    
    UIImage *cachedImage = [[self cache] objectForKey:imageURL.absoluteString];
    if ( cachedImage != nil )
    {
        completion( cachedImage, NO );
        return;
    }
    
    __weak typeof(self) welf = self;
    dispatch_async( resizeQueue, ^
                   {
                       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                       if ( image != nil )
                       {
                           UIImage *resized = [image smoothResizedImageWithNewSize:size];
                           dispatch_async( dispatch_get_main_queue(), ^
                                          {
                                              [[welf cache] setObject:resized forKey:imageURL.absoluteString];
                                              if ( completion != nil )
                                              {
                                                  completion( resized, YES );
                                              }
                                          });
                       }
                   });
    
}

@end
