//
//  VPurchaseManager+Debug.m
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//
#if DEBUG

#import "VPurchaseManager+Debug.h"

#define SIMULATE_PURCHASE                   1 || TARGET_IPHONE_SIMULATOR
#define SIMULATE_PRODUCTS_FETCH             1 || TARGET_IPHONE_SIMULATOR
#define SIMULATE_RESTORE_PURCHASE           1 || TARGET_IPHONE_SIMULATOR
#define SIMULATE_PURCHASE_ERROR             1
#define SIMULATE_FETCH_PRODUCTS_ERROR       1
#define SIMULATE_RESTORE_PURCHASE_ERROR     1
#define SIMULATION_DELAY                    2.0f

#if SIMULATE_PURCHASE || SIMULATE_PRODUCTS_FETCH || SIMULATE_RESTORE_PURCHASE
#warning VPurchaseManager is simulating one or more successful StoreKit interactions
#endif

#if SIMULATE_PURCHASE_ERROR || SIMULATE_FETCH_PRODUCTS_ERROR || SIMULATE_RESTORE_PURCHASE_ERROR
#warning VPurchaseManager is simulating one or more failed StoreKit interactions
#endif

@implementation VPurchaseManager (Debug)

- (void)simulatePurchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback
{
#if SIMULATE_PURCHASE
    self.activePurchase = [[VPurchase alloc] initWithProduct:[[VProduct alloc] init] success:successCallback failure:failureCallback];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SIMULATION_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       NSString *productIdentifier = @"test";
#if SIMULATE_PURCHASE_ERROR
                       [self transactionDidFailWithErrorCode:SKErrorUnknown productIdentifier:productIdentifier];
#else
                       [self transactionDidCompleteWithProductIdentifier:productIdentifier];
#endif
                   });
    return;
#endif
}

@end

#endif