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

#import "UIImage+Resize.h"

@import Photos;

@interface VAssetGridViewController ()

@property (nonatomic, strong) PHFetchResult *allPhotosResult;

@property (nonatomic, strong) UIImage *selectedFullSizeImage;
@property (nonatomic, strong) NSURL *imageFileURL;

@end

@implementation VAssetGridViewController

@synthesize handler;

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
    __weak typeof(self) welf = self;
//    [[PHImageManager defaultManager] requestImageForAsset:asset
//                                               targetSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//                                              contentMode:PHImageContentModeDefault
//                                                  options:fullSizeRequestOptions
//                                            resultHandler:^(UIImage *result, NSDictionary *info)
//     {
//         welf.selectedFullSizeImage = result;
//     }];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:fullSizeRequestOptions
                                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             [progressHud hide:YES afterDelay:0.25f];
         });
         [welf callCompletionWithAsset:asset
                              imageData:imageData
                               orientation:orientation
                                      info:info];
         VLog(@"request handler info: %@", info);
     }];
}

- (void)callCompletionWithAsset:(PHAsset *)asset
                      imageData:(NSData *)imageData
                    orientation:(UIImageOrientation)orientation
                           info:(NSDictionary *)info
{
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        UIImage *imageWithProperOrientation = [[UIImage imageWithCGImage:imageFromData.CGImage scale:1.0f orientation:orientation] fixOrientation];
        NSURL *urlForAsset = [welf temporaryURLForAsset:asset];
        [welf saveImage:imageWithProperOrientation
                  toURL:urlForAsset];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            __strong typeof (welf) strongSelf = welf;
            strongSelf.selectedFullSizeImage = imageWithProperOrientation;
            strongSelf.imageFileURL = urlForAsset;
            
#warning Remove me
            NSData *dataWithURL = [NSData dataWithContentsOfURL:urlForAsset];
            UIImage *imageFromData = [UIImage imageWithData:dataWithURL];
            
            if (strongSelf.handler != nil)
            {
                strongSelf.handler(strongSelf.selectedFullSizeImage, strongSelf.imageFileURL);
            }
        });
    });
}

- (void)saveImage:(UIImage *)image
            toURL:(NSURL *)fileURL
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    NSError *error = nil;
    [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
}

- (NSURL *)temporaryURLForAsset:(PHAsset *)asset
{
    NSURL *baseURL = [self cacheDirectoryURL];
    
    NSUUID *uuid = [NSUUID UUID];
    
    return  [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpeg", uuid.UUIDString]];
}

- (NSURL *)cacheDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
}


- (PHAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [self.allPhotosResult objectAtIndex:indexPath.row];
}

@end
