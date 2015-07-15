//
//  VAssetCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetCollectionViewCell.h"

@interface VAssetCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *selectionView;

@end

@implementation VAssetCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.selectionView.alpha = 0.0f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.selectionView.alpha = selected ? 1.0f : 0.0f;
}

#pragma mark - Property Accessors

- (void)setAsset:(PHAsset *)asset
{
    if (![_asset.localIdentifier isEqualToString:asset.localIdentifier])
    {
        // We now represent a new asset
        self.imageView.image = nil;
    }
    _asset = asset;

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = self.imageView.bounds.size;
    CGSize desiredSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.version = PHImageRequestOptionsVersionCurrent;
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    requestOptions.networkAccessAllowed = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self.imageManager requestImageForAsset:asset
                                     targetSize:desiredSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:requestOptions
                                  resultHandler:^(UIImage *result, NSDictionary *info)
         {
             if ([_asset.localIdentifier isEqualToString:asset.localIdentifier])
             {
                 self.imageView.image = result;
             }
         }];
    });
}

@end
