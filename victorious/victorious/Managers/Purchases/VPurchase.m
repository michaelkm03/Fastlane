//
//  VPurchase.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchase.h"
#import "VProduct.h"

@implementation VPurchase

- (instancetype)initWithProduct:(VProduct *)product
                        success:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( product != nil );
        NSParameterAssert( successCallback != nil );
        NSParameterAssert( failureCallback != nil );
        
        _product = product;
        _failureCallback = failureCallback;
        _successCallback = successCallback;
    }
    return self;
}


- (instancetype)initWithSuccess:(VPurchaseSuccessBlock)successCallback
                        failure:(VPurchaseFailBlock)failureCallback
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( successCallback != nil );
        NSParameterAssert( failureCallback != nil );
        
        _failureCallback = failureCallback;
        _successCallback = successCallback;
        
        _restoreProductIdentifiers = [[NSMutableSet alloc] init];
    }
    return self;
}

@end
