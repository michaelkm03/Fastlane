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
        
        _thumbnailCache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - VTrimmerThumbnailDataSource

- (void)trimmerViewController:(VTrimmerViewController *)trimmer
             thumbnailForTime:(CMTime)requestedTime
               withCompletion:(void (^)(UIImage *thumbnail, CMTime timeForImage, id generatingDataSource))completion
{
    NSParameterAssert(completion != nil);
    
    NSString *keyForThumbnail = [NSString stringWithFormat:@"%@", [NSValue valueWithCMTime:requestedTime]];
    UIImage *cachedImage = [self.thumbnailCache objectForKey:keyForThumbnail];
    if (cachedImage != nil)
    {
        completion(cachedImage, requestedTime, self);
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:requestedTime]]
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         UIImage *generatedImage = [UIImage imageWithCGImage:image
                                                       scale:1.0f
                                                 orientation:UIImageOrientationUp];
         [welf.thumbnailCache setObject:generatedImage
                                 forKey:keyForThumbnail];
         completion(generatedImage, requestedTime, welf);
     }];
}

@end
