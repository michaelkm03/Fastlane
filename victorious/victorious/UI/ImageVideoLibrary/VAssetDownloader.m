//
//  VAssetDownloader.m
//  victorious
//
//  Created by Michael Sena on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetDownloader.h"

@implementation VAssetDownloader

- (instancetype)initWithAsset:(PHAsset *)asset
{
    return [super init];
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (void)downloadWithProgress:(void (^)(BOOL accurateProgress, double progress, NSString *localizedProgress))progressHandler
                  completion:(void (^)(NSError *error, NSURL *downloadedFileURL, UIImage *previewImage))completion
{
    NSAssert(false, @"Implement in subclasses!");
}

@end
