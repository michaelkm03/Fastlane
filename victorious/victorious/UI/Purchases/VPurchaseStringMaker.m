//
//  VPurchaseStringMaker.m
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseStringMaker.h"

@implementation VPurchaseStringMaker

- (NSString *)localizedSuccessMessageWithProductsCount:(NSUInteger)count
{
    if ( count == 0 )
    {
        return NSLocalizedString( @"RestorePurchasesNoPurchases", nil );
    }
    else
    {
        return NSLocalizedString( @"RestorePurchasesSuccess", nil);
    }
}

- (NSString *)localizedSuccessTitleWithProductsCount:(NSUInteger)count
{
    if ( count == 0 )
    {
        return NSLocalizedString( @"RestorePurchasesNoPurchasesTitle", nil );
    }
    else if ( count == 1 )
    {
        return [NSString stringWithFormat:NSLocalizedString( @"RestorePurchasesSuccessTitleSingular", nil), count];
    }
    else
    {
        return [NSString stringWithFormat:NSLocalizedString( @"RestorePurchasesSuccessTitlePlural", nil), count];
    }
}

@end
