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
          andVideoComposition:(AVVideoComposition *)videoComposition
{
    self = [super init];
    if (self)
    {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;
        _imageGenerator.maximumSize = CGSizeMake(128, 128);
        _imageGenerator.videoComposition = videoComposition;
    }
    return self;
}

#pragma mark - VTrimmerThumbnailDataSource

- (void)trimmerViewController:(VTrimmerViewController *)trimmer
             thumbnailForTime:(CMTime)time
               withCompletion:(void (^)(UIImage *thumbnail, CMTime timeForImage))completion
{
    NSParameterAssert(completion != nil);
    
    NSString *keyForThumbnail = [NSString stringWithFormat:@"%@", [NSValue valueWithCMTime:time]];
    UIImage *cachedImage = [self.thumbnailCache objectForKey:keyForThumbnail];
    if (cachedImage != nil)
    {
        completion(cachedImage, time);
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]]
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         UIImage *generatedImage = [UIImage imageWithCGImage:image
                                                       scale:1.0f
                                                 orientation:UIImageOrientationUp];
         completion(generatedImage, time);
     }];
}

@end
