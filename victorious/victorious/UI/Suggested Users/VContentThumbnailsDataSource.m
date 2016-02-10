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
#import "VStreamItem+Fetcher.h"
#import "VTextSequencePreviewView.h"

typedef void (^ResizingCompletion)(UIImage *image, BOOL didDownload, NSInteger index);
typedef UIImage* (^ImageLoading)();

@interface VContentThumbnailsDataSource()

@property (nonatomic, strong) VImageAssetFinder *assetFinder;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VContentThumbnailsDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if ( self != nil )
    {
        _assetFinder = [[VImageAssetFinder alloc] init];
        _collectionView = collectionView;
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
    CGSize imageSize = [delegate collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    //Multiply size of cell by screen scale to get size of image needed to display at proper resolution
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    imageSize.height *= screenScale;
    imageSize.width *= screenScale;
    
    NSString *identifier = [VContentThumbnailCell suggestedReuseIdentifier];
    VContentThumbnailCell *cell = (VContentThumbnailCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ( cell != nil )
    {
        NSInteger index = indexPath.row;
        VSequence *sequence = self.sequences[ index ];
        __weak typeof(cell) weakCell = cell;
        [self loadImageFromSequence:sequence withSize:imageSize atIndex:index completion:^(UIImage *image, BOOL didDownload, NSInteger loadedIndex)
         {
             VContentThumbnailCell *strongCell = weakCell;
             if ( strongCell == nil )
             {
                 return;
             }
             
             NSIndexPath *indexPath = [collectionView indexPathForCell:strongCell];
             if ( indexPath.row == loadedIndex || !didDownload )
             {
                 [strongCell setImage:image animated:didDownload];
             }
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

- (void)loadImageFromSequence:(VSequence *)sequence withSize:(CGSize)size atIndex:(NSInteger)index completion:(ResizingCompletion)completion
{
    if ( [sequence.itemSubType isEqualToString:VStreamItemSubTypeText] )
    {
        NSString *cacheKey = sequence.remoteId;
        UIImage *cachedImage = [[self cache] objectForKey:cacheKey];
        if ( cachedImage != nil )
        {
            completion( cachedImage, NO, index );
            return;
        }
        VTextSequencePreviewView *textSequencePreviewView = [[VTextSequencePreviewView alloc] init];
        textSequencePreviewView.displaySize = size;
        textSequencePreviewView.onlyShowPreview = YES;
        textSequencePreviewView.dependencyManager = self.dependencyManager;
        [textSequencePreviewView updateToStreamItem:sequence];
        __weak typeof(self) welf = self;
        [textSequencePreviewView renderTextPostPreviewImageWithCompletion:^(UIImage *image)
         {
             __strong VContentThumbnailsDataSource *strongSelf = welf;
             if ( strongSelf == nil )
             {
                 return;
             }
             [strongSelf performOnResizeQueue:^
              {
                  [strongSelf resizeAndCacheImage:image withCacheKey:cacheKey toSize:size atIndex:index withCompletion:completion];
              }];
         }];
    }
    else
    {
        VImageAsset *asset = [self.assetFinder assetWithPreferredMinimumSize:size fromAssets:sequence.previewImageAssets];
        NSURL *imageURL = [NSURL URLWithString:asset.imageURL];
        NSString *cacheKey = imageURL.absoluteString;
        UIImage *cachedImage = [[self cache] objectForKey:cacheKey];
        if ( cachedImage != nil )
        {
            completion( cachedImage, NO, index );
            return;
        }
        __weak typeof(self) welf = self;
        [self performOnResizeQueue:^
         {
             UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
             [welf resizeAndCacheImage:image withCacheKey:cacheKey toSize:size atIndex:index withCompletion:completion];
         }];
    }
}

- (void)performOnResizeQueue:(void (^)(void))queuedBlock
{
    static dispatch_queue_t resizeQueue;
    if ( resizeQueue == nil )
    {
        resizeQueue = dispatch_queue_create( "com.victorious.suggestedUsersResizeQueue", DISPATCH_QUEUE_CONCURRENT );
    }
    
    dispatch_async( resizeQueue, ^
                   {
                       queuedBlock();
                   });
}

- (void)resizeAndCacheImage:(UIImage *)image withCacheKey:(NSString *)cacheKey toSize:(CGSize)size atIndex:(NSInteger)index withCompletion:(ResizingCompletion)completion
{
    if ( image != nil )
    {
        CGSize imageSize = image.size;
        CGFloat aspectRatio = imageSize.width / imageSize.height;
        __block UIImage *resized = nil;
        if ( aspectRatio == 1.0f )
        {
            //1:1 image, use the desired size
            imageSize = size;
        }
        else if ( aspectRatio > 1.0f )
        {
            //Wider than it is tall, enforce our desired height and make the width such that the aspect ratio is preserved.
            imageSize.width = size.width;
            imageSize.height = VCEIL(imageSize.width / aspectRatio);
        }
        else if ( aspectRatio < 1.0f )
        {
            //Taller than it is wide, enforce our desired width and make the height such that the aspect ratio is preserved.
            imageSize.height = size.height;
            imageSize.width = VCEIL(imageSize.height * aspectRatio);
        }
        
        resized = [image smoothResizedImageWithNewSize:imageSize];
        
        __weak typeof(self) welf = self;
        dispatch_async( dispatch_get_main_queue(), ^
                       {
                           [[welf cache] setObject:resized forKey:cacheKey];
                           if ( completion != nil )
                           {
                               completion( resized, YES, index );
                           }
                       });
    }
}

@end
