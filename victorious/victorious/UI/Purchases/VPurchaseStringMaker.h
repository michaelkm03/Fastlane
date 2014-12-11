//
//  VPurchaseStringMaker.h
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

/**
 Helper class that creates user-facing messages for the results of restoring purchases.
 */
@interface VPurchaseStringMaker : NSObject

/**
 Returns a localized alert title that indicates how many purchases were restored.
 */
- (NSString *)localizedSuccessMessageWithProductsCount:(NSUInteger)count;

/**
 Returns a localized alert message that indicates how many purchases were restored.
 */
- (NSString *)localizedSuccessTitleWithProductsCount:(NSUInteger)count;

@end
