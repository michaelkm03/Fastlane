//
//  VProduct.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import StoreKit;

/**
 A wrapper for SKPRoduct to abstract away any StoreKit functionality from calling code.
 */
@interface VProduct : NSObject

- (instancetype)initWithStoreKitProduct:(SKProduct *)storeKitProduct;

@property (nonatomic, readonly) SKProduct *storeKitProduct;

@end
