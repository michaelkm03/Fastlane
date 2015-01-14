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
        _imageGenerator.appliesPreferredTrackTransform = YES;
    }
    return self;
}

- (void)generateThumbnailsOverRange:(CMTimeRange)timeRange
                         completion:(void (^)(BOOL finished))completion
{
    NSMutableArray *times = [[NSMutableArray alloc] init];
    CMTime totalTime = CMTimeAdd(timeRange.start, timeRange.duration);
    CMTime createdTime = kCMTimeZero;
    while (CMTIME_COMPARE_INLINE(createdTime, <, totalTime))
    {
        createdTime = CMTimeAdd(createdTime, self.thumbnailInterval);
        [times addObject:[NSValue valueWithCMTime:createdTime]];
    }
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
    {
        completion((result == AVAssetImageGeneratorSucceeded) ? YES : NO);
    }];
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
