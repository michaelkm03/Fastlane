//
//  VProduct.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import StoreKit;

#import "VProduct.h"

@interface VProduct()

@property (nonatomic, readonly) NSNumberFormatter *priceNumberFormatter;

@end

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

- (NSNumberFormatter *)priceNumberFormatter
{
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
                  {
                      formatter = [[NSNumberFormatter alloc] init];
                      [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                      [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                      [formatter setLocale:[self.storeKitProduct priceLocale]];
                  });
    return formatter;
}

- (NSString *)price
{
    NSDecimalNumber *decimalPrice = [self.storeKitProduct price];
    return [self.priceNumberFormatter stringFromNumber:decimalPrice];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-property-ivar"
- (NSString *)productIdentifier
{
#if SIMULATE_STOREKIT
    return _productIdentifier;
#else
    VLog(@"%@", _productIdentifier);
    return _storeKitProduct.productIdentifier;
#endif
}
#pragma clang diagnostic pop

- (NSString *)localizedTitle
{
    return self.storeKitProduct.localizedTitle;
}

- (NSString *)localizedDescription
{
    return self.storeKitProduct.localizedDescription;
}

@end
