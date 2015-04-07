//
//  NSURL+VAssetCache.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAsset.h"

@interface NSURL (VAssetCache)

+ (NSURL *)cacheURLForAsset:(VAsset *)asset;

@end
