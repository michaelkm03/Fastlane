//
//  VPurchaseManagerType.h
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@import Foundation;

@class VProduct;

#import "VProductsRequest.h"
#import "VPurchase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an object that interacts with StoreKit in order to make purchases of IAP
 and subscriptions.
 */
@protocol VPurchaseManagerType

/**
 Should return YES if a successful products request has returned and there are products
 available for purchase (or that are already purchased).  The idea is that if no valid
 products can be found, we should assume that purchasing is not enabled.  This could
 also be the case if an error is preventing products from being loaded, but in most cases
 the application should behave in the same way.
 */
@property (nonatomic, readonly) BOOL isPurchasingEnabled;

/**
 Should return YES if a products fetch request, purchase restore or purchase is in progress.
 Proper state management in this class depends on only one request being active and will
 throw an assertion if calling code tries to send another request of these kinds.  Make sure
 this property returns NO before doing any of these things.
 */
@property (nonatomic, readonly) BOOL isPurchaseRequestActive;

/**
 Should return the product identifiers of In-App purchases
 the user has made or restored on this device as stored in the purchased record.
 */
@property (nonatomic, readonly) NSSet *purchasedProductIdentifiers;

/**
 Should return YES if productIdentifier is listed in the local purchased record.
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
 product in the parameter of the success callback, or use purchaseableProductForProductIdentifier
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
 Load full product information for the product identifiers supplied.  This method must
 be called first in order to provide VProduct objects, which are required to make a
 purchase of the corresponding product on iTunesConnect.
 */
- (void)fetchProductsWithIdentifiers:(NSSet *)productIdentifiers
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback;

/**
 Should return a VProduct object that corresponds to the suppied product identifier
 if that product has successfully fetched from the App Store from a previous call to
 fetchProductsWithIdentifiers:success:failure.
 */
- (VProduct *)purchaseableProductForProductIdentifier:(NSString *)productIdentifier;

@end

NS_ASSUME_NONNULL_END
