//
//  VPurchaseManager.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;

#import "VProductsRequest.h"
#import "VProduct.h"
#import "VPurchase.h"
#import "VPurchaseManagerType.h"

/**
 Posted when a successful call to `fetchProductsWithIdentifiers:success:failure` returns.
 This is needed to update and UI that lists purchaseable products.
 */
NSString * const VPurchaseManagerProductsDidUpdateNotification;

@interface VPurchaseManager : NSObject <VPurchaseManagerType>

/**
 Returns the singleton instance.  For better or for worse, this manager should be
 a singleton because of the nature of StoreKit's transaction and product request queues.
 During development, some transactions will be left unfinished between app launches,
 which causes StoreKit to try to finish them upon the next app launch.  Not only can this
 mess up state management, but if the SKProductsRequestDelegate and SKPaymentTransactionObserver
 relations are not set up soon after app launch, StoreKit will try to call methods
 on non-existent delegate objects and the app will crash without so much as a meaningful
 stack trace.
 */
+ (VPurchaseManager *)sharedInstance;

#ifdef V_RESET_PURCHASES

/**
 For testing a debugging purposes, this will erase the local purchase record.
 */
- (void)resetPurchases;

/**
 For testing a debugging purposes, any product IDs that are being treated as purchased
 even though they may not have actually been purchased.
 */
@property (nonatomic, strong) NSMutableSet *simulatedPurchasedProductIdentifiers;

#endif

@end
