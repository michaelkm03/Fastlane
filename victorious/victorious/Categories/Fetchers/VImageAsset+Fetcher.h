//
//  VImageAsset+Fetcher.h
//  victorious
//
//  Created by Patrick Lynch on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageAsset.h"

@interface VImageAsset (Fetcher)

+ (VImageAsset *)assetWithMinimumSize:(CGSize)minimumSize fromAssets:(NSSet *)imageAssets;

+ (VImageAsset *)assetWithMaximumSize:(CGSize)maximumSize fromAssets:(NSSet *)imageAssets;

- (CGFloat)area;

- (BOOL)isSmallerThanSize:(CGSize)size;

- (BOOL)isLargerThanSize:(CGSize)size;

@end
