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
 An array of VProduct objects that represents any purchases made or restored
 during the lifetime of this instance of VPurchaseManager.
 */
@property (nonatomic, readonly) NSArray *purchaseableProducts;

/**
 An array of VProduct objects that contains the results of any calls
 to fetchProductsWithIdentifiers:success:failure.
 */
@property (nonatomic, readonly) NSArray *purchasedProducts;

/**
 Begin the process of purchasing the supplied product as an In-App Purchase
 through the App Store.  The user will seubsequently have to confirm and
 enter his or her iTunes credentials.  To get a product to purchase, first
 use fetchProductsWithIdentifiers:success:failsure.
 
 In addition to providing the VProduct object that was just purchased, that same product
 and any other purchased products as a parameter in the success callback, this instance
 VPurchaseManager provides the same VProduct objects in its purchasedProducts property.
 */
- (void)purchaseProduct:(VProduct *)product
                success:(VPurchaseSuccessBlock)successCallback
                failure:(VPurchaseFailBlock)failureCallback;

/**
 Begin the process of retriving all previously purchased products so that they may be
 supplied to the user.  This is necessary if the user has re-installed the app after 
 having previously made purchases.  The user will seubsequently have to confirm and
 enter his or her iTunes credentials.
 
 In addition to providing an array of VProduct objects for each of the previously
 purchased products as a parameter in the success callback, this instance VPurchaseManager
 provides the same VProduct objects in its purchasedProducts property.
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

@end
