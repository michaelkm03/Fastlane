//
//  VAsset+Fetcher.h
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VAsset.h"

@interface VAsset (Fetcher)

+ (NSArray*)orderedAssetsForNode:(VNode*)node;

@end
