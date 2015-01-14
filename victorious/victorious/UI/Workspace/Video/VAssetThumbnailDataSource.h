//
//  VAssetThumbnailDataSource.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

@import AVFoundation;

@interface VAssetThumbnailDataSource : NSObject <VTrimmerThumbnailDataSource>

- (instancetype)initWithAsset:(AVAsset *)asset;

@property (nonatomic, assign) CMTime thumbnailInterval;

- (void)generateThumbnailsOverRange:(CMTimeRange)timeRange
                         completion:(void (^)(BOOL finished))completion;

@end
