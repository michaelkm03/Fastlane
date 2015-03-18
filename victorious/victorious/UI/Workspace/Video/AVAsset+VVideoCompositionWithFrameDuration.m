//
//  AVAsset+VVideoCompositionWithFrameDuration.m
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "AVAsset+VVideoCompositionWithFrameDuration.h"

@implementation AVAsset (VVideoCompositionWithFrameDuration)

- (AVVideoComposition *)videoCompositionWithFrameDuration:(CMTime)frameDuration
{
    AVMutableVideoComposition *videoComposition = [[AVVideoComposition videoCompositionWithPropertiesOfAsset:self] mutableCopy];
    videoComposition.frameDuration = frameDuration;
    
    // Force render size to be a multiple of 16
    CGSize renderSize = videoComposition.renderSize;
    NSInteger renderWidth = (NSInteger)renderSize.width;
    NSInteger remainderWidth = (renderWidth % 16) ;
    if (remainderWidth != 0)
    {
        renderWidth = renderWidth - remainderWidth;
    }
    renderSize.width = renderWidth;
    NSInteger renderHeight = (NSInteger)renderSize.height;
    NSInteger remainderHeight = (renderHeight % 16) ;
    if (remainderHeight != 0)
    {
        renderHeight = renderHeight - remainderHeight;
    }
    renderSize.height = renderHeight;
    videoComposition.renderSize = renderSize;
    
    return [videoComposition copy];
}

@end
