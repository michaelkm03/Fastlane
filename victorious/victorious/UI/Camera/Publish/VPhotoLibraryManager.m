//
//  VPhotoLibraryManager.m
//  victorious
//
//  Created by Josh Hinman on 10/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VPhotoLibraryManager.h"

@import AssetsLibrary;

const NSInteger VPhotoLibraryManagerIncompatibleVideoErrorCode = 999;
const NSInteger VPhotoLibraryManagerUnknownAssetTypeErrorCode = 998;
NSString * const VPhotoLibraryManagerErrorDomain = @"VPhotoLibraryManagerErrorDomain";

@implementation VPhotoLibraryManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)saveMediaAtURL:(NSURL *)media toPhotoLibraryWithCompletion:(VPhotoLibraryManagerCompletionBlock)completion
{
    if ([media v_hasVideoExtension])
    {
        if (![self.assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:media])
        {
            if (completion)
            {
                completion([NSError errorWithDomain:VPhotoLibraryManagerErrorDomain code:VPhotoLibraryManagerIncompatibleVideoErrorCode userInfo:nil]);
            }
            return;
        }
        [self.assetsLibrary writeVideoAtPathToSavedPhotosAlbum:media completionBlock:^(NSURL *assetURL, NSError *error)
        {
            if (completion)
            {
                completion(error);
            }
        }];
    }
    else if ([media v_hasImageExtension])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:[media path]];
        [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error)
        {
            if (completion)
            {
                completion(error);
            }
        }];
    }
    else if (completion)
    {
        completion([NSError errorWithDomain:VPhotoLibraryManagerErrorDomain code:VPhotoLibraryManagerUnknownAssetTypeErrorCode userInfo:nil]);
    }
}

@end
