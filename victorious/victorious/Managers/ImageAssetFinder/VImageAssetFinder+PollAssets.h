//
//  VImageAssetFinder+PollAssets.h
//  victorious
//
//  Created by Patrick Lynch on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAssetFinder.h"

@interface VImageAssetFinder (PollAssets)

/**
 From the provided set, returns the VAnswer corresponding to poll answer A
 */
- (VAnswer *)answerAFromAssets:(NSSet *)assets;

/**
 From the provided set, returns the VAnswer corresponding to poll answer B
 */
- (VAnswer *)answerBFromAssets:(NSSet *)assets;

@end
