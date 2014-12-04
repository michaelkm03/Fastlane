//
//  VPurchaseManagerCache.h
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPurchaseManagerCache : NSObject

@property (nonatomic, strong) NSCache *purchaseableProducts;
@property (nonatomic, strong) NSCache *purchasedProducts;

@end