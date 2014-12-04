//
//  VPurchaseManagerCache.h
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VProductCache : NSCache

- (NSArray *)objectsForKeys:(NSArray *)keys;

@end

@interface VPurchaseManagerCache : NSObject

@property (nonatomic, strong) VProductCache *purchaseableProducts;
@property (nonatomic, strong) VProductCache *purchasedProducts;

@end