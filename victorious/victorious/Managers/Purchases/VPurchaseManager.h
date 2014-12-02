//
//  VPurchaseManager.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;

#import "VProductsRequest.h"
#import "VPurchase.h"

@interface VPurchaseManager : NSObject

- (void)purchaseProduct:(VProduct *)product
                success:(VPurchaseSuccessBlock)successCallback
                failure:(VPurchaseFailBlock)failureCallback;

- (void)restorePurchasesSuccess:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback;

- (void)fetchProductsWithIdentifiers:(NSArray *)productIdenfiters
                             success:(VProductsRequestSuccessBlock)successCallback
                             failure:(VProductsRequestFailureBlock)failureCallback;

@end
