//
//  VVoteType+ImageSerialization.h
//  victorious
//
//  Created by Patrick Lynch on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVoteType.h"

extern NSString * const VVoteTypeImageIndexReplacementMacro;

@interface VVoteType (ImageSerialization)

@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) BOOL canCreateImages;
@property (nonatomic, readonly) BOOL containsRequiredData;

@end
