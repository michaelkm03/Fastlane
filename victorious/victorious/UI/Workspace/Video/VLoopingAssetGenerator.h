//
//  VLoopingAssetGenerator.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@class AVAsset;
@import CoreMedia;

@interface VLoopingAssetGenerator : NSObject

- (instancetype)initWithURL:(NSURL *)assetURL;

- (void)startLoading;

- (void)setTrimRange:(CMTimeRange)trimRange
      withCompletion:(void (^)(AVAsset *loopedAsset))completion;

@property (nonatomic, readonly) CMTime assetOriginalDuration;

@property (nonatomic, copy) void (^loopedAssetBecameAvailable)(AVAsset *loopedAsset);

@end
