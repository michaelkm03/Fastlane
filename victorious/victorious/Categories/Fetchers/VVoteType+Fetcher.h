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

/**
 Objects of type VVoteType may have a string value assigned to their `productIdentifier`
 property that indicates that corresponds to a product for sale as an In-App Purchase configured
 in iTunesConnect.  This method returns an NSSet of product identifiers from any objects in the
 `voteTypes' parameter.  Returns nil if those none of the VVoteType's supplied are purchaseable.
 */
+ (NSSet *)productIdentifiersFromVoteTypes:(NSArray *)voteTypes;

@property (nonatomic, readonly) UIViewContentMode contentMode;
@property (nonatomic, readonly) NSArray *images;
@property (nonatomic, readonly) BOOL canCreateImages;
@property (nonatomic, readonly) BOOL containsRequiredData;
@property (nonatomic, readonly) BOOL hasValidTrackingData;
@property (nonatomic, readonly) BOOL mustBePurchased;

@end
