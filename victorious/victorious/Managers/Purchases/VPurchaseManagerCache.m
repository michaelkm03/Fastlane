//
//  VPurchaseManagerCache.m
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseManagerCache.h"

@implementation VPurchaseManagerCache

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _purchaseableProducts = [[NSCache alloc] init];
        _purchasedProducts = [[NSCache alloc] init];
    }
    return self;
}

@end
