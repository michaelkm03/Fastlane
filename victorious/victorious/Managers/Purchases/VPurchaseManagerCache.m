//
//  VPurchaseManagerCache.m
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseManagerCache.h"
#import "VProduct.h"

@implementation VProductCache

- (NSArray *)objectsForKeys:(NSArray *)keys
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
    {
        id obj = [self objectForKey:key];
        if ( obj != nil && [obj isKindOfClass:[VProduct class]] )
        {
            [objects addObject:obj];
        }
    }];
    return [NSArray arrayWithArray:objects];
}

@end

@implementation VPurchaseManagerCache

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _purchaseableProducts = [[VProductCache alloc] init];
        _purchasedProducts = [[VProductCache alloc] init];
    }
    return self;
}

@end
