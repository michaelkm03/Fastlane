//
//  VProduct.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;
@class SKProduct;

NS_ASSUME_NONNULL_BEGIN

/**
 A wrapper for SKPRoduct to abstract away any StoreKit functionality from calling code.
 */
@interface VProduct : NSObject

- (instancetype)initWithStoreKitProduct:(SKProduct *)storeKitProduct;

@property (nonatomic, strong) NSString *productIdentifier;
@property (nonatomic, readonly, nullable) NSString *price;
@property (nonatomic, readonly, nullable) NSString *localizedDescription;
@property (nonatomic, readonly, nullable) NSString *localizedTitle;
@property (nonatomic, readonly) SKProduct *storeKitProduct;

@end

NS_ASSUME_NONNULL_END
