//
//  VProduct.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;
@class SKProduct;

/**
 A wrapper for SKPRoduct to abstract away any StoreKit functionality from calling code.
 */
@interface VProduct : NSObject

- (instancetype)initWithStoreKitProduct:(SKProduct *)storeKitProduct;

@property (nonatomic, readonly) NSString *price;
@property (nonatomic, readonly) NSString *localizedDescription;
@property (nonatomic, readonly) NSString *localizedTitle;
@property (nonatomic, readonly) NSString *productIdentifier;

@property (nonatomic, strong) SKProduct *storeKitProduct;

@end
