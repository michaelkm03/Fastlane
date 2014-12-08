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

/**
 The API for In-App Purchases in this application.
 */
@interface VPurchaseManager : NSObject

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

/**
 Returns YES if productIdentifier is listed in the local purchased record.
 */
- (BOOL)isProductIdentifierPurchased:(NSString *)productIdentifier;

/**
 Begin the process of purchasing the supplied product as an In-App Purchase
 through the App Store.  The user will seubsequently have to confirm and
 enter his or her iTunes credentials.  To obtain information about this product,
 such as its price, use fetchProductsWithIdentifiers:success:failure.
 */
- (void)purchaseProductWithIdentifier:(NSString *)productIdentifier
                              success:(VPurchaseSuccessBlock)successCallback
                              failure:(VPurchaseFailBlock)failureCallback;

/**
 Begin the process of purchasing the supplied product as an In-App Purchase
 through the App Store.  The user will seubsequently have to confirm and
 enter his or her iTunes credentials.  To get a product to purchase, first
 use fetchProductsWithIdentifiers:success:failure and grab a reference to the
 product in the parameter of the success callback, or use purchaseableProductForProductIdenfitier
 to access it from the internal cache of fetched products.
 */
- (void)purchaseProduct:(VProduct *)product
                success:(VPurchaseSuccessBlock)successCallback
                failure:(VPurchaseFailBlock)failureCallback;

/**
 Begin the process of retriving all previously purchased products so that they may be
 supplied to the user.  This is necessary if the user has re-installed the app after 
 having previously made purchases.  The user will seubsequently have to confirm and
 enter his or her iTunes credentials.
 */
- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback;

/**
 Loads full product information for the product identifiers supplied.  This method must
 be called first in order to provide VProduct objects, which are required to make a
 purchase of the corresponding product on iTunesConnect.
 */
- (void)fetchProductsWithIdentifiers:(NSArray *)productIdenfiters
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback;

/**
 Returns a VProduct object that corresponds to the suppied product identifier
 if that product has successfully fetched from the App Store from a previous call to
 fetchProductsWithIdentifiers:success:failure.
 */
- (VProduct *)purchaseableProductForProductIdenfitier:(NSString *)productIdentifier;

@end
