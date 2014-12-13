//
//  VProduct.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#if DEBUG || TARGET_IOS_SIMULATOR
#import "VPurchaseDebugSettings.h"
#endif

@import Foundation;
@class SKProduct;

/**
 A wrapper for SKPRoduct to abstract away any StoreKit functionality from calling code.
 */
@interface VProduct : NSObject

- (instancetype)initWithStoreKitProduct:(SKProduct *)storeKitProduct;

#if SIMULATE_STOREKIT
@property (nonatomic, strong) NSString *productIdentifier;
#else
@property (nonatomic, readonly) NSString *productIdentifier;
#endif

@property (nonatomic, readonly) NSString *price;
@property (nonatomic, readonly) NSString *localizedDescription;
@property (nonatomic, readonly) NSString *localizedTitle;
@property (nonatomic, readonly) SKProduct *storeKitProduct;

@end
