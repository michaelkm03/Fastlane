//
//  VPurchaseManager+Debug.h
//  victorious
//
//  Created by Patrick Lynch on 12/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//
#if DEBUG

#import "VPurchaseManager.h"

@interface VPurchaseManager (Debug)

- (void)simulateSuccessfulPurchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback;

- (void)simulateFailedPurchaseProduct:(VProduct *)product success:(VPurchaseSuccessBlock)successCallback failure:(VPurchaseFailBlock)failureCallback;

@end

#endif