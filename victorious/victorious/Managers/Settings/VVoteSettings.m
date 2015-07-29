//
//  VVoteSettings.m
//  victorious
//
//  Created by Patrick Lynch on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteSettings.h"
#import "VVoteType.h"
#import "VPurchaseManager.h"

@implementation VVoteSettings

- (void)setVoteTypes:(NSArray *)voteTypes
{
    // Error checking
    if ( voteTypes == nil || voteTypes.count == 0 )
    {
        return;
    }
    // Check that only objects of type VVoteType are accepted
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VVoteType *voteType, NSDictionary *bindings)
                              {
                                  return [voteType isMemberOfClass:[VVoteType class]] &&
                                  voteType.containsRequiredData;
                              }];
    _voteTypes = [(_voteTypes ?: @[]) arrayByAddingObjectsFromArray:voteTypes];
    _voteTypes = [voteTypes filteredArrayUsingPredicate:predicate];
    
    [self fetchProducts];
}

- (VVoteType *)voteTypeWithProductIdentifier:(NSString *)productIdentifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier];
    return [self.voteTypes filteredArrayUsingPredicate:predicate].firstObject;
}

- (void)fetchProducts
{
    if ( self.voteTypes == nil || self.voteTypes.count == 0 )
    {
        return;
    }
    
    NSSet *productIdentifiers = [VVoteType productIdentifiersFromVoteTypes:self.voteTypes];
    VPurchaseManager *purchaseManager = [VPurchaseManager sharedInstance];
    if ( !purchaseManager.isPurchaseRequestActive )
    {
        [purchaseManager fetchProductsWithIdentifiers:productIdentifiers success:nil failure:nil];
    }
}

@end
