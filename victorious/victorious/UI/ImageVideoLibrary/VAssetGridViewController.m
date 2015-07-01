//
//  VAssetGridViewController.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetGridViewController.h"

// Views + Helpers
#import "VAssetCollectionViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>

@import Photos;

@interface VAssetGridViewController ()

@property (nonatomic, strong) PHFetchResult *allPhotosResult;

@end

@implementation VAssetGridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHFetchOptions *allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    self.allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[VAssetCollectionViewCell suggestedReuseIdentifier]
                                                                                forIndexPath:indexPath];
    
    PHAsset *assetAtIndexPath = [self assetForIndexPath:indexPath];
    
    [[PHImageManager defaultManager] requestImageForAsset:assetAtIndexPath
                                               targetSize:CGSizeMake(95, 95)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         VAssetCollectionViewCell *cellForResult = (VAssetCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
         cellForResult.imageView.image = result;
     }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self downloadAsset:[self assetForIndexPath:indexPath]];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

#pragma mark - Private Methods

- (void)downloadAsset:(PHAsset *)asset
{
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    progressHud.mode = MBProgressHUDModeAnnularDeterminate;
    progressHud.dimBackground = YES;
    [progressHud show:YES];
    
    PHImageRequestOptions *fullSizeRequestOptions = [[PHImageRequestOptions alloc] init];
    fullSizeRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    fullSizeRequestOptions.version = PHImageRequestOptionsVersionCurrent;
    fullSizeRequestOptions.networkAccessAllowed = YES;
    fullSizeRequestOptions.progressHandler = ^void(double progress, NSError *error, BOOL *stop, NSDictionary *info)
    {
        VLog(@"download progress: %f", progress);
        progressHud.progress = progress;
    };
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeDefault
                                                  options:fullSizeRequestOptions
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {

     }];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:fullSizeRequestOptions
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         [progressHud hide:YES afterDelay:0.25f];

         UIImage *imageFromData = [UIImage imageWithData:imageData];
         UIImage *imageWithProperOrientation = [UIImage imageWithCGImage:imageFromData.CGImage scale:1.0f orientation:orientation];

         VLog(@"request handler info: %@", info);
     }];
}

- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.allPhotosResult objectAtIndex:indexPath.row];
}

@end
