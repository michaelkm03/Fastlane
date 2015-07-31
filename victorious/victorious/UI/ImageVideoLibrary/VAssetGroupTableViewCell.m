//
//  VAssetGroupTableViewCell.m
//  victorious
//
//  Created by Michael Sena on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetGroupTableViewCell.h"

@import Photos;

@interface VAssetGroupTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;

@end

@implementation VAssetGroupTableViewCell

- (void)setAsset:(PHAsset *)asset
{
    _asset = asset;
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:self.groupImageView.bounds.size
                                              contentMode:PHImageContentModeDefault
                                                  options:requestOptions
                                            resultHandler:^(UIImage *result, NSDictionary *info)
     {
         dispatch_async(dispatch_get_main_queue(), ^
         {
             if (self.asset == asset)
             {
                 self.groupImageView.image = result;
             }
         });
     }];
}

@end
