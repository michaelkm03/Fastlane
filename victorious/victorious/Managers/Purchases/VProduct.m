//
//  VProduct.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProduct.h"

@implementation VProduct

- (instancetype)initWithStoreKitProduct:(SKProduct *)storeKitProduct
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( storeKitProduct != nil );
        
        _storeKitProduct = storeKitProduct;
    }
    return self;
}

@end
