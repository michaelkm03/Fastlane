//
//  VAsset+Fetcher.h
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAsset.h"

@interface VAsset (Fetcher)

- (BOOL)isYoutube;
- (BOOL)isImage;
- (BOOL)isVideo;

@end
