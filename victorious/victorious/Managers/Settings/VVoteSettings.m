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

NSString * const VVoteSettingsDidUpdateNotification = @"VVoteSettingsDidUpdateNotification";
NSString * const VVoteSettingsDidUpdateKeyVoteType = @"VVoteSettingsDidUpdateKeyVoteType";

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
    [self.fileCache cacheImagesForVoteTypes:_voteTypes];
    
#warning Testing only to create correctly configurd purchaseable products
    [voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         NSUInteger order = voteType.displayOrder.unsignedIntegerValue;
         if ( order == 1 )
         {
             voteType.isPaid = @YES;
             voteType.productIdentifier = [NSString stringWithFormat:@"com.getvictorious.eatyourkimchi.testpurchase.000%lu", (unsigned long)order];
             *stop = YES;
         }
     }];
    
    [self fetchProducts];
}

- (void)fetchProducts
{
    if ( self.voteTypes == nil || self.voteTypes.count == 0 )
    {
        return;
    }
    
    NSArray *productIdentifiers = [VVoteType productIdentifiersFromVoteTypes:self.voteTypes];
    [[VPurchaseManager sharedInstance] fetchProductsWithIdentifiers:productIdentifiers success:nil failure:nil];
}

- (void)didCompletePurchaseWithProductIdentifiers:(NSArray *)productIdentifiers
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(VVoteType *voteType, NSDictionary *bindings)
    {
        return [productIdentifiers containsObject:voteType.productIdentifier];
    }];
    
    NSArray *matches = [self.voteTypes filteredArrayUsingPredicate:predicate];
    if ( matches.count == 0 )
    {
        return;
    }
    
    [matches enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
     {
         voteType.isPurchased = @YES;
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VVoteSettingsDidUpdateNotification object:nil];
}

@end
