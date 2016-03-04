//
//  VPurchase.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;
@import StoreKit;

@class VProduct;

typedef void (^VPurchaseSuccessBlock) (NSSet *);
typedef void (^VPurchaseFailBlock) (NSError *);
typedef void (^ReceiptValidationSuccessBlock) (BOOL);
typedef void (^ReceiptValidationFailureBlock) (NSError *);

@interface VPurchase : NSObject

- (instancetype)initWithProduct:(VProduct *)product
                        success:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback;

- (instancetype)initWithSuccess:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback;

@property (nonatomic, readonly) VProduct *product;
@property (nonatomic, readonly) VPurchaseSuccessBlock successCallback;
@property (nonatomic, readonly) VPurchaseFailBlock failureCallback;

@property (nonatomic, strong) NSMutableSet *restoredProductIdentifiers;

@end
