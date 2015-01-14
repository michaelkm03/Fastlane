//
//  VAssetThumbnailDataSource.m
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAssetThumbnailDataSource.h"

@interface VAssetThumbnailDataSource ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSCache *thumbnailCache;

@end

@implementation VAssetThumbnailDataSource

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self)
    {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
        _imageGenerator.maximumSize = CGSizeMake(128, 128);
        _thumbnailInterval = CMTimeMake(1, 1);
    }
    return self;
}

#pragma mark - VTrimmerThumbnailDataSource

- (void)trimmerViewController:(VTrimmerViewController *)trimmer
             thumbnailForTime:(CMTime)time
               withCompletion:(void (^)(UIImage *thumbnail, CMTime timeForImage))completion
{
    UIImage *cachedImage = [self.thumbnailCache objectForKey:[NSValue valueWithCMTime:time].description];
    if (cachedImage != nil)
    {
        completion(cachedImage, time);
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]]
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         UIImage *generatedImage = [UIImage imageWithCGImage:image];
         completion(generatedImage, time);
     }];
}

@end
