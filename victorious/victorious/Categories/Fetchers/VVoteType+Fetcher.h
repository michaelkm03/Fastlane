//
//  VVoteType+Fetcher.h
//  victorious
//
//  Created by Will Long on 3/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteType.h"

extern NSString * const VVoteTypeImageIndexReplacementMacro;

@interface VVoteType (Fetcher)

+ (NSArray *)productIdentifiersFromVoteTypes:(NSArray *)voteTypes;

@property (nonatomic, readonly) UIViewContentMode contentMode;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) BOOL canCreateImages;
@property (nonatomic, readonly) BOOL containsRequiredData;
@property (nonatomic, readonly) BOOL hasValidTrackingData;

@end
