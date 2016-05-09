//
//  VMockPurchaseManager.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPurchaseManagerType.h"

@interface VMockPurchaseManager : NSObject <VPurchaseManagerType>

@property (nonatomic, assign) BOOL isPurchaseRequestActive;
@property (nonatomic, strong) NSSet *purchasedProductIdentifiers;

@end
