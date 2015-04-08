//
//  VAsset+VCachedData.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAsset.h"

@interface VAsset (VCachedData)

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 *
 *  This has not been fully engineered for general use. Only supports one download task at a time.
 *
 */
- (BOOL)assetDataIsCached;

@end
