//
//  Asset+RestKit.h
//  victoriOS
//
//  Created by Will Long on 11/30/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAsset.h"
#import "NSManagedObject+RestKit.h"

@interface VAsset (RestKit)

+ (RKEntityMapping *)entityMappingForVVoteType;

/**
 Provides a mapping for a text post represented in a preview array of a
 stream or sequence. Will return nil if there is no text asset to map to.
 */
+ (RKDynamicMapping *)textPostPreviewEntityMapping;

@end
