//
//  VMockPurchaseManager.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "VMockPurchaseManager.h"

@implementation VMockPurchaseManager

- (BOOL)isProductIdentifierPurchased:(NSString *)productIdentifier
{
    return NO;
}

- (void)purchaseProductWithIdentifier:(NSString *)productIdentifier
                              success:(VPurchaseSuccessBlock)successCallback
                              failure:(VPurchaseFailBlock)failureCallback
{
    successCallback( [NSSet set] );
}

- (VPurchaseType)purchaseTypeForProductIdentifier:(NSString *)productIdentifier
{
    return VPurchaseTypeProduct;
}

- (void)purchaseProduct:(VProduct *)product
                success:(VPurchaseSuccessBlock)successCallback
                failure:(VPurchaseFailBlock)failureCallback
{
    successCallback( [NSSet set] );
}

- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback
{
    successCallback( [NSSet set] );
}

- (void)fetchProductsWithIdentifiers:(NSArray<NSString *> *)productIdentifiers
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback
{
    successCallback( [NSSet set] );
}

- (VProduct *)purchaseableProductForProductIdentifier:(NSString *)productIdentifier
{
    return nil;
}

- (void)resetPurchases
{
    
}

@end
