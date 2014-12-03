//
//  VProductsRequest.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProductsRequest.h"

#import "VProduct.h"
@interface VProductsRequest()

@property (nonatomic, assign) NSUInteger productsFailedCount;

@end

@implementation VProductsRequest

- (instancetype)initWithProductIdentifiers:(NSArray *)productIndenfiters
                                   success:(VProductsRequestSuccessBlock)successCallback
                                   failure:(VProductsRequestFailureBlock)failureCallback
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( productIndenfiters != nil );
        NSParameterAssert( productIndenfiters.count > 0 );
        
        _successCallback = successCallback;
        _failureCallback = failureCallback;
        _productIdentifiers = productIndenfiters;
        
        _products = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)productFetched:(SKProduct *)product
{
    [self.products addObject:product];
}

- (void)productIdentifierFailedToFetch:(NSString *)productIdentifier
{
    self.productsFailedCount++;
}

- (BOOL)isFetchComplete
{
    return self.products.count + self.productsFailedCount == self.productIdentifiers.count;
}

@end
