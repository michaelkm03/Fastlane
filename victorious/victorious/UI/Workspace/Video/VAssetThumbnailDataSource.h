//
//  VAssetThumbnailDataSource.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

@import AVFoundation;

/**
 A Thumbnail data source.
 */
@interface VAssetThumbnailDataSource : NSObject <VTrimmerThumbnailDataSource>

- (instancetype)initWithAsset:(AVAsset *)asset NS_DESIGNATED_INITIALIZER;

@end
