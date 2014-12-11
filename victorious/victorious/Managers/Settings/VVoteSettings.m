//
//  VVoteSettings.m
//  victorious
//
//  Created by Patrick Lynch on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVoteSettings.h"
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VVoteType+Fetcher.h"
#import "VPurchaseManager.h"

#define OVERWRITE_WITH_PAID_BALLISTICS 1

@interface VVoteSettings()

@property (nonatomic, strong) VFileCache *fileCache;

@end

@implementation VVoteSettings

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.fileCache = [[VFileCache alloc] init];
    }
    return self;
}

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
                                  voteType.containsRequiredData &&
                                  voteType.hasValidTrackingData;
                              }];
    _voteTypes = [(_voteTypes ?: @[]) arrayByAddingObjectsFromArray:voteTypes];
    _voteTypes = [voteTypes filteredArrayUsingPredicate:predicate];
    
#if OVERWRITE_WITH_PAID_BALLISTICS
#warning Testing only to create correctly configured purchaseable products
    ((VVoteType *)_voteTypes[0]).isPaid = @YES;
    ((VVoteType *)_voteTypes[0]).productIdentifier = @"com.getvictorious.eatyourkimchi.ballistic.meemers";
    ((VVoteType *)_voteTypes[0]).iconImage = @"http://10.18.11.38:8000/meemers-icon.png";
    ((VVoteType *)_voteTypes[0]).iconImageLarge = @"http://10.18.11.38:8000/meemers-product-image.png";
    ((VVoteType *)_voteTypes[1]).isPaid = @YES;
    ((VVoteType *)_voteTypes[1]).productIdentifier = @"com.getvictorious.eatyourkimchi.ballistic.spudgy";
    ((VVoteType *)_voteTypes[1]).iconImage = @"http://10.18.11.38:8000/spudgy-icon.png";
    ((VVoteType *)_voteTypes[1]).iconImageLarge = @"http://10.18.11.38:8000/spudgy-product-image.png";
#endif
    
    [self.fileCache cacheImagesForVoteTypes:_voteTypes];
    
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
