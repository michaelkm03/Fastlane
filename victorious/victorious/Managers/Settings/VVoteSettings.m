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
#import "NSArray+VMap.h"

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
}

- (VVoteType *)voteTypeWithProductIdentifier:(NSString *)productIdentifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentifier == %@", productIdentifier];
    return [self.voteTypes filteredArrayUsingPredicate:predicate].firstObject;
}

- (NSArray<NSString *> *)getProductIdentifiers
{
    return [self.voteTypes v_map:^(VVoteType *voteType)
    {
        return voteType.productIdentifier;
    }];
}

@end
