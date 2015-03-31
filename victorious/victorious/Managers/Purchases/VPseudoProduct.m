//
//  VPseudoProduct.m
//  victorious
//
//  Created by Josh Hinman on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPseudoProduct.h"

@implementation VPseudoProduct
{
    NSString *_productIdentifier;
    NSString *_price;
    NSString *_localizedDescription;
    NSString *_localizedTitle;
}

- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier price:(NSString *)price localizedDescription:(NSString *)localizedDescription localizedTitle:(NSString *)localizedTitle
{
    self = [super init];
    if ( self != nil )
    {
        _productIdentifier = [productIdentifier copy];
        _price = [price copy];
        _localizedDescription = [localizedDescription copy];
        _localizedTitle = [localizedTitle copy];
    }
    return self;
}

- (NSString *)productIdentifier
{
    return _productIdentifier;
}

- (NSString *)price
{
    return _price;
}

- (NSString *)localizedTitle
{
    return _localizedTitle;
}

- (NSString *)localizedDescription
{
    return _localizedDescription;
}

- (SKProduct *)storeKitProduct
{
    return nil;
}

@end
